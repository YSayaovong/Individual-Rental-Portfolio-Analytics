# Rental Portfolio Operations Analytics System
### PostgreSQL Data Mart + Power BI Executive Dashboard

---

## Overview

This project is an **operations analytics system** for rental portfolio performance. It models rental income, expenses, late payments, and CAPEX as a structured dataset, then converts that into decision-ready KPIs for:

- **Collections & cash flow stability**
- **NOI and margin discipline**
- **Expense variance + root-cause drivers**
- **CAPEX planning**
- **Property-level performance benchmarking**

The goal is the same as manufacturing ops analytics: **tight controls, fast visibility, and better decisions**.

> Note: Data is anonymized / simulated to protect confidentiality while preserving real operational patterns.

---

## Business Context (Operations Lens)

Rental portfolios fail when operators lose control of:
- collections timing (late payments / delinquency)
- expense variance (repairs, utilities, taxes, insurance)
- CAPEX surprises (big-ticket maintenance)
- property-level margin drift

This system provides a repeatable analytics workflow to monitor performance and highlight risk early.

---

## What This System Delivers

### Executive KPIs
- Total Income, Total Expenses, **NOI**
- **Cash Flow** (monthly / trailing)
- Late Payment Rate (%), Delinquency Trend
- Expense Variance vs Baseline
- CAPEX Spend + Forecast Runway
- Property Benchmark Rank (top/bottom performers)

### Root Cause Analytics
- Pareto of expense drivers
- Variance decomposition (Property → Category → Vendor/Type)
- Late payment drivers by property / tenant segment (if available)

---

## Tech Stack

- **PostgreSQL**: data mart (facts + dimensions)
- **Power BI**: executive reporting + drilldowns
- **Python (pandas)**: data prep + KPI automation

---

## Data Model (Star Schema)

### Fact Tables
- `fact_transactions` (income/expense/capex events)
- `fact_payments` (billing, paid date, late status)

### Dimensions
- `dim_property`
- `dim_date`
- `dim_category` (expense/income type)
- `dim_vendor` (optional)
- `dim_tenant` (optional)

This structure supports scalable KPI queries and clean Power BI relationships.

---

## Repo Structure

