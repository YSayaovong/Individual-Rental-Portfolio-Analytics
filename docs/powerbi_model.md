# Power BI model (Data Analyst focus)

## Tables to import
Option A (fastest): Import the CSVs directly.
- Tenants_Table.csv
- Invoices_Table.csv
- Payments_Table.csv
- Expenses_Table.csv

Option B (cleaner for portfolio): Import marts from Postgres
- mart.vw_invoice_rollup
- mart.vw_monthly_cashflow
- mart.vw_monthly_noi
- mart.vw_monthly_expenses
- mart.vw_ar_aging
- mart.vw_tenant_ledger
- mart.vw_payment_method_mix

## Relationships (if using CSV direct)
- Tenants[tenant_id] 1-* Invoices[tenant_id]
- Invoices[invoice_id] 1-* Payments[invoice_id]
- Tenants[tenant_id] 1-* Payments[tenant_id]

Create a Date table and relate:
- Date[Date] 1-* Invoices[due_date]
- Date[Date] 1-* Payments[payment_date]
- Date[Date] 1-* Expenses[expense_date]

## Pages
### 1) Executive Summary
Cards:
- Rent Billed
- Rent Collected
- Collection Rate
- Expenses
- NOI
- Outstanding AR

Charts:
- Line: monthly NOI
- Columns: billed vs collected

Slicers:
- Date (month)
- Tenant
- Payment method

### 2) Accounts Receivable
- AR aging matrix (0–30/31–60/61–90/90+)
- Tenant ledger table with running balance
- Drillthrough page: Tenant Detail

### 3) Expenses
- Monthly expenses trend
- Category breakdown (treemap)
- Vendor table (top vendors)

