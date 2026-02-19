# Rental Portfolio Operations Analytics System

SQL Data Mart • Power BI Dashboard • KPI Engine • Dockerized Postgres

A complete end-to-end Operations Analytics project built to mirror how a manufacturing/operations analyst designs, validates, and reports performance for recurring revenue operations.

This system consolidates Expenses, Invoices, Payments, and Tenants into a clean SQL data mart, applies KPI logic, and feeds a Power BI model that surfaces margin, cash flow, variance, and payment-timeliness trends.

Even though the dataset is rental-based, the structure is identical to a manufacturing environment:

- Invoices → Shipments / Production Orders
- Payments → Customer Cash Collections
- Expenses → Operating Costs / Maintenance / Materials
- Tenants → Customers / Accounts

## 1. Project Overview

This project demonstrates my ability to build an operational analytics system using:

- PostgreSQL (schema design, transformations, KPI views)
- Power BI (DAX measures, semantic model, interactive reports)
- Docker (reproducible data environment)
- CSV operational datasets
- Data modeling techniques used in manufacturing, logistics, finance, and operations teams

The system answers core operational questions:

- Are we profitable month over month?
- Which categories drive cost variance?
- Is our cash flow stable?
- Who is consistently late on payments?
- How do expenses compare across periods?

## 2. Architecture

CSV Data Sources → PostgreSQL (Dockerized) → Power BI Semantic Model → Executive Dashboard

## 3. Dataset (CSV Layer)

1. Expenses_Table.csv
2. Invoices_Table.csv
3. Payments_Table.csv
4. Tenants_Table.csv

## 4. SQL Layer

Includes schema creation, KPI views, payment timeliness logic, and monthly rollups.

## 5. Power BI Layer

Includes:
- DAX measures
- Date intelligence
- Revenue, expenses, payment trends
- Drilldowns by category and time

## 6. Docker Environment

docker-compose.yml sets up a reproducible PostgreSQL environment for running all SQL files.

## 7. Key Insights (Examples)

- Identified high variance in recurring expenses
- Detected late payment patterns using Days Late KPIs
- Stabilized month-to-month cash flow reporting with SQL views
- Built category-level cost visibility

## 8. Interview Talking Points

- SQL data modeling for operations
- KPI definitions for performance management
- Power BI semantic modeling & DAX
- How rental data maps 1:1 to manufacturing/operations analytics

## 9. How to Run

1. Load CSVs into Postgres
2. Run postgres_build.sql
3. Run rental_financial_analytics.sql
4. Open Power BI → Refresh model → Explore dashboards

