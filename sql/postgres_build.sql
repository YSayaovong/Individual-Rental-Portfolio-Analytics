-- Rental Analytics (DA-focused) — PostgreSQL build
-- Creates: stg tables + mart views for Power BI
-- Safe to re-run: drops and recreates schemas.

BEGIN;

DROP SCHEMA IF EXISTS stg CASCADE;
DROP SCHEMA IF EXISTS mart CASCADE;

CREATE SCHEMA stg;
CREATE SCHEMA mart;

-- =========================
-- 1) STAGING TABLES
-- =========================
CREATE TABLE stg.tenants (
  tenant_id        TEXT PRIMARY KEY,
  name             TEXT NOT NULL,
  lease_start_date DATE,
  lease_end_date   DATE,
  status           TEXT,
  family           TEXT
);

CREATE TABLE stg.invoices (
  invoice_id   TEXT PRIMARY KEY,
  tenant_id    TEXT NOT NULL REFERENCES stg.tenants(tenant_id),
  rent_month   DATE NOT NULL,
  rent_amount  NUMERIC(12,2) NOT NULL,
  due_date     DATE NOT NULL,
  status       TEXT NOT NULL
);

CREATE TABLE stg.payments (
  payment_id     TEXT PRIMARY KEY,
  invoice_id     TEXT NOT NULL REFERENCES stg.invoices(invoice_id),
  tenant_id      TEXT NOT NULL REFERENCES stg.tenants(tenant_id),
  payment_date   DATE NOT NULL,
  amount_paid    NUMERIC(12,2) NOT NULL,
  payment_method TEXT
);

CREATE TABLE stg.expenses (
  expense_id   TEXT PRIMARY KEY,
  vendor       TEXT,
  category     TEXT,
  amount       NUMERIC(12,2) NOT NULL,
  expense_date DATE NOT NULL,
  notes        TEXT
);

-- =========================
-- 2) OPTIONAL: LOAD CSVs VIA COPY
-- =========================
-- Update file paths to your local machine if you use psql:
-- \copy stg.tenants  FROM 'Tenants_Table.csv'  CSV HEADER;
-- \copy stg.invoices FROM 'Invoices_Table.csv' CSV HEADER;
-- \copy stg.payments FROM 'Payments_Table.csv' CSV HEADER;
-- \copy stg.expenses FROM 'Expenses_Table.csv' CSV HEADER;

-- =========================
-- 3) MART VIEWS (POWER BI READY)
-- =========================

-- 3.1 Invoice rollup: applied payments + balance + first payment date
CREATE OR REPLACE VIEW mart.vw_invoice_rollup AS
WITH pay AS (
  SELECT
    invoice_id,
    MIN(payment_date) AS first_payment_date,
    SUM(amount_paid)  AS total_paid
  FROM stg.payments
  GROUP BY 1
)
SELECT
  i.invoice_id,
  i.tenant_id,
  i.rent_month,
  i.due_date,
  i.status AS invoice_status,
  i.rent_amount,
  COALESCE(p.total_paid, 0) AS total_paid,
  (i.rent_amount - COALESCE(p.total_paid, 0)) AS balance,
  p.first_payment_date,
  CASE
    WHEN p.first_payment_date IS NULL THEN NULL
    ELSE (p.first_payment_date - i.due_date)
  END AS days_late
FROM stg.invoices i
LEFT JOIN pay p USING (invoice_id);

-- 3.2 Monthly cashflow: billed vs collected + collection rate
CREATE OR REPLACE VIEW mart.vw_monthly_cashflow AS
WITH billed AS (
  SELECT DATE_TRUNC('month', rent_month)::date AS month,
         SUM(rent_amount) AS rent_billed
  FROM stg.invoices
  GROUP BY 1
),
collected AS (
  SELECT DATE_TRUNC('month', payment_date)::date AS month,
         SUM(amount_paid) AS rent_collected
  FROM stg.payments
  GROUP BY 1
)
SELECT
  COALESCE(b.month, c.month) AS month,
  COALESCE(b.rent_billed, 0) AS rent_billed,
  COALESCE(c.rent_collected, 0) AS rent_collected,
  CASE WHEN COALESCE(b.rent_billed,0) = 0 THEN NULL
       ELSE COALESCE(c.rent_collected,0) / COALESCE(b.rent_billed,0)
  END AS collection_rate
FROM billed b
FULL OUTER JOIN collected c
  ON b.month = c.month
ORDER BY 1;

-- 3.3 Monthly expenses
CREATE OR REPLACE VIEW mart.vw_monthly_expenses AS
SELECT
  DATE_TRUNC('month', expense_date)::date AS month,
  category,
  SUM(amount) AS expenses
FROM stg.expenses
GROUP BY 1,2;

-- 3.4 NOI by month (collected - expenses)
CREATE OR REPLACE VIEW mart.vw_monthly_noi AS
WITH cf AS (
  SELECT month, rent_collected
  FROM mart.vw_monthly_cashflow
),
ex AS (
  SELECT DATE_TRUNC('month', expense_date)::date AS month,
         SUM(amount) AS total_expenses
  FROM stg.expenses
  GROUP BY 1
)
SELECT
  COALESCE(cf.month, ex.month) AS month,
  COALESCE(cf.rent_collected,0) AS rent_collected,
  COALESCE(ex.total_expenses,0) AS total_expenses,
  COALESCE(cf.rent_collected,0) - COALESCE(ex.total_expenses,0) AS noi
FROM cf
FULL OUTER JOIN ex
  ON cf.month = ex.month
ORDER BY 1;

-- 3.5 AR aging: bucket open balances by days past due (as of today)
CREATE OR REPLACE VIEW mart.vw_ar_aging AS
WITH open_inv AS (
  SELECT *
  FROM mart.vw_invoice_rollup
  WHERE balance > 0.01
),
aged AS (
  SELECT
    tenant_id,
    invoice_id,
    due_date,
    balance,
    (CURRENT_DATE - due_date) AS days_past_due
  FROM open_inv
)
SELECT
  tenant_id,
  COUNT(*) AS open_invoices,
  SUM(balance) AS ar_total,
  SUM(CASE WHEN days_past_due <= 30 THEN balance ELSE 0 END) AS ar_0_30,
  SUM(CASE WHEN days_past_due BETWEEN 31 AND 60 THEN balance ELSE 0 END) AS ar_31_60,
  SUM(CASE WHEN days_past_due BETWEEN 61 AND 90 THEN balance ELSE 0 END) AS ar_61_90,
  SUM(CASE WHEN days_past_due > 90 THEN balance ELSE 0 END) AS ar_90_plus
FROM aged
GROUP BY 1;

-- 3.6 Tenant ledger: running balance (invoice increases, payments decrease)
CREATE OR REPLACE VIEW mart.vw_tenant_ledger AS
WITH inv AS (
  SELECT tenant_id,
         due_date AS txn_date,
         invoice_id AS ref_id,
         'invoice'::text AS txn_type,
         rent_amount AS amount
  FROM stg.invoices
),
pay AS (
  SELECT tenant_id,
         payment_date AS txn_date,
         payment_id AS ref_id,
         'payment'::text AS txn_type,
         -amount_paid AS amount
  FROM stg.payments
),
u AS (
  SELECT * FROM inv
  UNION ALL
  SELECT * FROM pay
)
SELECT
  tenant_id,
  txn_date,
  txn_type,
  ref_id,
  amount,
  SUM(amount) OVER (PARTITION BY tenant_id ORDER BY txn_date, txn_type, ref_id) AS running_balance
FROM u;

-- 3.7 Payment method mix
CREATE OR REPLACE VIEW mart.vw_payment_method_mix AS
SELECT
  payment_method,
  COUNT(*) AS payment_count,
  SUM(amount_paid) AS amount_paid
FROM stg.payments
GROUP BY 1
ORDER BY 3 DESC;

COMMIT;

-- =========================
-- 4) RECONCILIATION CHECKS (run as needed)
-- =========================
-- Total invoiced vs total paid vs open balance:
-- SELECT
--   SUM(rent_amount) AS total_invoiced,
--   SUM(total_paid) AS total_paid,
--   SUM(balance) AS total_open_balance
-- FROM mart.vw_invoice_rollup;
