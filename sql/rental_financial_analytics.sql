-- Rental Portfolio Restore Script

-- Drop tables if they already exist
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS tenants;

-- Create tenants table
CREATE TABLE tenants (
    tenant_id VARCHAR(10) PRIMARY KEY,
    name TEXT NOT NULL,
    lease_start_date DATE NOT NULL,
    lease_end_date DATE,
    status VARCHAR(20) NOT NULL,
    family VARCHAR(30) NOT NULL
);

-- Create invoices table
CREATE TABLE invoices (
    invoice_id VARCHAR(10) PRIMARY KEY,
    tenant_id VARCHAR(10) REFERENCES tenants(tenant_id),
    rent_month DATE NOT NULL,
    rent_amount DECIMAL(10,2) NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR(10) NOT NULL
);

-- Create payments table
CREATE TABLE payments (
    payment_id VARCHAR(10) PRIMARY KEY,
    invoice_id VARCHAR(10) REFERENCES invoices(invoice_id),
    tenant_id VARCHAR(10) REFERENCES tenants(tenant_id),
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(10) NOT NULL
);

-- Create expenses table
CREATE TABLE expenses (
    expense_id VARCHAR(10) PRIMARY KEY,
    vendor TEXT NOT NULL,
    category VARCHAR(20) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    expense_date DATE NOT NULL,
    notes TEXT
);

-- Example INSERTS (few sample rows to get you started)
-- You can add more later

INSERT INTO tenants (tenant_id, name, lease_start_date, lease_end_date, status, family) VALUES
('TEN001', 'John Doe', '2010-04-01', '2014-05-30', 'Past', 'Family with Kids'),
('TEN002', 'Jane Smith', '2014-06-01', '2019-01-15', 'Past', 'Family without Kids'),
('TEN003', 'Michael Brown', '2019-02-01', NULL, 'Current', 'Family with Kids');

INSERT INTO invoices (invoice_id, tenant_id, rent_month, rent_amount, due_date, status) VALUES
('INV0001', 'TEN001', '2010-04-01', 850.00, '2010-04-01', 'Paid'),
('INV0002', 'TEN002', '2014-06-01', 900.00, '2014-06-01', 'Paid'),
('INV0003', 'TEN003', '2019-02-01', 950.00, '2019-02-01', 'Unpaid');

INSERT INTO payments (payment_id, invoice_id, tenant_id, payment_date, amount_paid, payment_method) VALUES
('PAY0001', 'INV0001', 'TEN001', '2010-04-03', 850.00, 'Check'),
('PAY0002', 'INV0002', 'TEN002', '2014-06-03', 900.00, 'Zelle');

INSERT INTO expenses (expense_id, vendor, category, amount, expense_date, notes) VALUES
('EXP0001', 'ABC Plumbing', 'Maintenance', 450.00, '2012-07-10', 'Water heater replacement'),
('EXP0002', 'DEF Insurance', 'Insurance', 1200.00, '2015-11-20', 'Annual property insurance renewal');

SELECT SUM(amount_paid) AS total_rental_income
FROM payments;

SELECT SUM(amount) AS total_expenses
FROM expenses;

SELECT 
  (SELECT SUM(amount_paid) FROM payments) - 
  (SELECT SUM(amount) FROM expenses) 
  AS net_operating_income;

SELECT COUNT(*) AS late_payments
FROM invoices
WHERE status = 'Unpaid';

SELECT category, SUM(amount) AS total_spent
FROM expenses
GROUP BY category
ORDER BY total_spent DESC
LIMIT 3;

SELECT 
  DATE_TRUNC('month', payment_date) AS month,
  SUM(amount_paid) AS total_rent_collected
FROM payments
GROUP BY month
ORDER BY month;

SELECT 
  DATE_TRUNC('month', expense_date) AS month,
  SUM(amount) AS total_expenses
FROM expenses
GROUP BY month
ORDER BY month;

WITH income AS (
  SELECT DATE_TRUNC('month', payment_date) AS month, SUM(amount_paid) AS rent
  FROM payments
  GROUP BY month
),
expenses AS (
  SELECT DATE_TRUNC('month', expense_date) AS month, SUM(amount) AS cost
  FROM expenses
  GROUP BY month
)
SELECT 
  COALESCE(i.month, e.month) AS month,
  COALESCE(i.rent, 0) AS rent,
  COALESCE(e.cost, 0) AS expenses,
  COALESCE(i.rent, 0) - COALESCE(e.cost, 0) AS net_income
FROM income i
FULL OUTER JOIN expenses e ON i.month = e.month
ORDER BY month;

WITH income AS (
  SELECT DATE_TRUNC('year', payment_date) AS year, SUM(amount_paid) AS rent
  FROM payments
  GROUP BY year
),
expenses AS (
  SELECT DATE_TRUNC('year', expense_date) AS year, SUM(amount) AS cost
  FROM expenses
  GROUP BY year
)
SELECT 
  COALESCE(i.year, e.year) AS year,
  COALESCE(i.rent, 0) AS rent,
  COALESCE(e.cost, 0) AS expenses,
  COALESCE(i.rent, 0) - COALESCE(e.cost, 0) AS net_income
FROM income i
FULL OUTER JOIN expenses e ON i.year = e.year
ORDER BY year;

SELECT 
  ROUND(100.0 * SUM(CASE 
    WHEN p.payment_date <= i.due_date THEN 1 
    ELSE 0 
  END)::NUMERIC / COUNT(*), 2) AS percent_on_time
FROM invoices i
JOIN payments p ON i.invoice_id = p.invoice_id;

SELECT 
  t.name,
  SUM(p.amount_paid) AS total_paid
FROM payments p
JOIN tenants t ON t.tenant_id = p.tenant_id
GROUP BY t.name
ORDER BY total_paid DESC;

SELECT 
  t.name,
  ROUND(AVG(i.rent_amount), 2) AS avg_rent_amount
FROM invoices i
JOIN tenants t ON t.tenant_id = i.tenant_id
GROUP BY t.name
ORDER BY avg_rent_amount DESC;

SELECT 
  (SELECT COUNT(*) FROM invoices) AS total_invoices,
  (SELECT COUNT(*) FROM payments) AS total_payments;