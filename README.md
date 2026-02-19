# Rental Portfolio Operations Analytics — Corrected README

## 1. Overview
This project models rental property operations using a full analytics pipeline:
CSV → PostgreSQL (Docker) → SQL KPIs → Power BI Dashboard.

It simulates operational financial processes such as rent collection, expenses, on‑time payments, and tenant performance — all mapped to an operations‑analytics workflow.

---

## 2. Dashboard Preview
*(Already in your GitHub; unchanged)*

---

## 3. Install & Run

### Step 1 — Start Docker Environment
```bash
docker-compose up -d
```

### Database Credentials
```
Host: localhost
Port: 5432
Database: rental
Username: rental_user
Password: rental_pass
```

### Step 2 — Connect with pgAdmin
Navigate to:  
http://localhost:8080  
Login using environment variables from docker-compose.

---

## 4. Dataset Schema

### tenants.csv
| Column | Description |
|--------|-------------|
| tenant_id | Unique tenant |
| tenant_name | Tenant full name |
| property_id | Property rented |

### invoices.csv
| Column | Description |
|--------|-------------|
| invoice_id | Unique invoice |
| tenant_id | Linked tenant |
| amount | Amount billed |
| due_date | Invoice due date |

### payments.csv
| Column | Description |
|--------|-------------|
| payment_id | Payment record |
| tenant_id | Linked tenant |
| amount | Amount paid |
| payment_date | Date of payment |
| status | On‑time / Late |

### expenses.csv
| Column | Description |
|--------|-------------|
| expense_id | Expense record |
| category | Insurance, maintenance, etc. |
| amount | Cost amount |
| expense_date | Date of expense |

---

## 5. Example KPI SQL

```sql
SELECT
    tenant_id,
    SUM(amount) AS total_payments,
    COUNT(*) FILTER (WHERE status = 'Late') AS late_payments
FROM payments
GROUP BY tenant_id;
```

---

## 6. Clean Docker Compose (Fixed)
```yaml
version: "3.9"

services:
  db:
    image: postgres:17-alpine
    container_name: rental_pg
    environment:
      POSTGRES_DB: rental
      POSTGRES_USER: rental_user
      POSTGRES_PASSWORD: rental_pass
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./data:/data

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: rental_pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@example.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "8080:80"
    depends_on:
      - db

volumes:
  pgdata:
```

---

## 7. Tools Used
- PostgreSQL
- Docker
- Power BI
- SQL (analytics layer)
- pgAdmin

---
