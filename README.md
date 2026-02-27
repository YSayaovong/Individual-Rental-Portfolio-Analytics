# Rental Portfolio Analytics

## 1. Project Background

As a data analyst managing a single-property rental operation, I built a full analytics pipeline to answer a question most small landlords never get to ask with confidence: *Is this property actually performing well — or does it just feel like it is?*

This project models 15 years of real rental operations (2010–2025) across five sequential tenants. Rather than relying on manual spreadsheet tracking, the data is structured in PostgreSQL via Docker, queried with SQL KPIs, and surfaced in a Power BI financial dashboard. The goal is to turn raw lease, payment, and expense records into a clear operational picture.

Insights and recommendations are structured around four key areas:

- **Rent Collection Performance:** Evaluating how consistently and how quickly tenants pay
- **Expense Analysis:** Understanding where money leaves the portfolio and when
- **Net Operating Income (NOI):** Measuring true profitability after all operating costs
- **Tenant Performance Comparison:** Benchmarking each tenant's financial behavior across their tenancy

---

## 2. Data Structure & Initial Checks

The dataset spans four tables with 431 total records covering April 2010 through early 2025.

```
tenants                              invoices
────────────────────                 ──────────────────────────
tenant_id     (PK, String)  ──────► tenant_id      (FK, String)
name          (String)               invoice_id     (PK, String)
lease_start_date (Date)              rent_month     (Date)
lease_end_date   (Date)              rent_amount    (Float)
status        (String)               due_date       (Date)
family        (String)               status         (String)
                                          │
                                          ▼
payments                             expenses
──────────────────────────           ──────────────────────────
payment_id    (PK, String)           expense_id     (PK, String)
invoice_id    (FK) ◄──────────────   vendor         (String)
tenant_id     (FK, String)           category       (String)
payment_date  (Date)                 amount         (Float)
amount_paid   (Float)                expense_date   (Date)
payment_method (String)              notes          (String)
```

| Table | Grain | Row Count |
|---|---|---|
| `tenants` | One row per tenant | 5 |
| `invoices` | One row per monthly rent invoice | 181 |
| `payments` | One row per payment made | 175 |
| `expenses` | One row per operating expense event | 70 |

**Initial Checks Performed:**
- Confirmed 5 tenants with sequential, non-overlapping lease dates — no gaps or overlaps in occupancy history
- 181 invoices issued, 175 paid — 6 invoices carry `Unpaid` status (all tied to one tenant)
- Payment dates were compared to invoice due dates to derive on-time vs. late classification
- Expense categories validated across four distinct types: Taxes, Maintenance, Repair, Insurance
- No null values found in amount fields across any table

---

## 3. Executive Summary

This rental property has operated continuously for 15 years across five tenants, collecting **$164,869 of $170,570 billed** — a **96.7% collection rate**. After $90,959 in operating expenses, the portfolio generated **$73,910 in Net Operating Income** at a **44.8% NOI margin**.

The headline numbers look strong. But beneath them is a payment timing problem: **92.6% of all payments were made after the due date**. Tenants consistently paid — they just paid late. This is a cash flow timing issue, not a collection failure, and it persists across all five tenants over 15 years, pointing to a lease structure problem rather than individual tenant behavior.

![Financial Dashboard](https://github.com/YSayaovong/rental-portfolio-operations-analytics/blob/main/assets/financial%20dashboard.PNG?raw=true)

| KPI | Value |
|---|---|
| Total Rent Billed | $170,570 |
| Total Rent Collected | $164,869 |
| Collection Rate | 96.7% |
| Total Operating Expenses | $90,959 |
| Net Operating Income (NOI) | $73,910 |
| NOI Margin | 44.8% |
| On-Time Payment Rate | 7.4% |
| Late Payment Rate | 92.6% |
| Avg Tenant Tenure (past tenants) | 45 months |

> **The core finding:** The property is profitable and well-occupied, with rent growing 48.9% over 15 years ($775 → $1,154/month). But a 92.6% chronic late payment rate across every tenant signals that the lease's due date and fee structure is not creating meaningful incentive to pay on time — and that is the primary operational risk to address.

---

## 4. Insights Deep Dive

### 4a. Rent Has Grown 48.9% Over 15 Years — Each New Tenant Captures the Increase

**Metric:** Monthly Rent Rate by Tenant, 2010–2025

**Finding:** Monthly rent has risen from $775 (Allison Hill, 2010) to $1,154 (Cristian Santos, 2025) — a **48.9% increase** over 15 years, averaging roughly **3.3% annually**. Every tenant transition has reset rent upward, creating a consistent appreciation cadence.

| Tenant | Tenure | Monthly Rent | Total Billed |
|---|---|---|---|
| Allison Hill | Apr 2010 – Jan 2015 (58 mo) | $775 | $47,516 |
| Noah Rhodes | Jan 2015 – May 2018 (40 mo) | $866 | $36,460 |
| Angie Henderson | May 2018 – May 2021 (36 mo) | $960 | $35,640 |
| Daniel Wagner | May 2021 – Mar 2025 (46 mo) | $1,038 | $49,800 |
| Cristian Santos | Mar 2025 – Active | $1,154 | $1,154 |

Each turnover is the primary rent reset mechanism — there are no mid-lease escalation clauses reflected in the data. With past-tenant average tenure of 45 months, rent appreciation is captured roughly every 3.75 years. Adding annual escalation clauses (e.g., CPI-linked or 3% fixed) to future leases would compound this growth without requiring turnover.

---

### 4b. 92.6% of Payments Were Late — but 96.7% of Invoices Were Eventually Collected

**Metric:** On-Time vs. Late Payment Rate; Invoice Collection Rate

**Finding:** Of 175 payments recorded, only **13 (7.4%) were made on or before the due date**. The remaining **162 (92.6%) were paid after the due date**. Yet the invoice collection rate is 96.7% — meaning tenants reliably pay, just not on time.

| Payment Timing | Count | % of Payments |
|---|---|---|
| On-Time (paid ≤ due date) | 13 | 7.4% |
| Late (paid > due date) | 162 | 92.6% |

This pattern is consistent across all five tenants over 15 years. When every tenant exhibits the same behavior, the lease terms are the common variable — not tenant quality. The current due date, grace period, and late fee structure are not creating sufficient incentive to pay on time.

Payment methods are split almost evenly: Check (34.3%), ACH (33.1%), and Zelle (32.6%). The lack of a dominant method adds administrative overhead. ACH auto-pay enrollment would be the most direct path to improving both timing and predictability.

---

### 4c. Angie Henderson Is the Only Tenant with a Meaningful Uncollected Balance

**Metric:** Total Billed vs. Collected by Tenant; Uncollected Amount

**Finding:** Four of five tenants reached 100% collection or near it. The exception is Angie Henderson (TEN003), who left a **$3,969 uncollected balance — 11.1% of her $35,640 total billed**. All other tenants, including Daniel Wagner who recorded the most late payments (45), ultimately paid in full.

| Tenant | Billed | Collected | Uncollected | Collection Rate |
|---|---|---|---|---|
| Allison Hill | $47,516 | $45,784 | $1,732 | 96.4% |
| Noah Rhodes | $36,460 | $36,460 | $0 | 100.0% |
| Angie Henderson | $35,640 | $31,671 | **$3,969** | **88.9%** |
| Daniel Wagner | $49,800 | $49,800 | $0 | 100.0% |
| Cristian Santos | $1,154 | $1,154 | $0 | 100.0% |

Angie Henderson's $3,969 gap is the equivalent of roughly 4 months of her $960 monthly rent going uncollected. Allison Hill's smaller $1,732 shortfall (3.6%) adds to the picture. A security deposit sized at 1.5–2 months' rent — paired with documented exit conditions — would have covered both gaps entirely.

---

### 4d. Taxes Consume 41% of Expenses — Maintenance and Repair Add Another 46.8%

**Metric:** Total Operating Expense Breakdown by Category

**Finding:** Total operating expenses over 15 years were **$90,959** across 70 recorded events. Property taxes are the largest single line at **$37,261 (41.0%)**, followed by Maintenance (**$21,679, 23.8%**) and Repair (**$20,847, 22.9%**) — which together represent **46.8% of all operating costs**.

| Category | Total Cost | % of Expenses | # of Events |
|---|---|---|---|
| Taxes | $37,261 | 41.0% | 23 |
| Maintenance | $21,679 | 23.8% | 16 |
| Repair | $20,847 | 22.9% | 19 |
| Insurance | $11,172 | 12.3% | 12 |

Three years stood out as significantly elevated: **2014 ($9,674)**, **2020 ($8,427)**, and **2018 ($7,737)**. These spikes align with tenant transitions (2015, 2018) and the pandemic period — patterns consistent with turnover-driven repairs and deferred maintenance catch-up. Conversely, 2023 ($1,955) and 2021 ($3,626) were the quietest years operationally.

---

### 4e. NOI Margin of 44.8% Is Solid — but Unevenly Distributed Across Years

**Metric:** Portfolio-Lifetime Net Operating Income and Margin

**Finding:** With $164,869 collected and $90,959 in expenses, the portfolio generated **$73,910 in NOI** at a **44.8% margin**. This is a healthy long-run figure for a single residential unit — but it masks significant year-to-year volatility driven by lumpy expense events.

High-expense years (2014, 2018, 2020 averaging $8,613) would have produced margins well below the 44.8% average, while low-expense years (2021, 2023) would have been substantially stronger. The expense structure — taxes (largely fixed) plus maintenance and repair (largely reactive) — creates an NOI profile that is predictable in direction but unpredictable in magnitude.

Proactive maintenance scheduling and a dedicated repair reserve would reduce the amplitude of expense spikes and improve cash flow predictability without changing the long-run NOI average.

---

## 5. Recommendations

Based on the above findings, the following actions are recommended:

- **Revise lease terms to incentivize on-time payment.** With 92.6% of payments arriving late across all five tenants over 15 years, the current due date and grace period structure is not working. Consider a small rent discount (e.g., $25–$50) for payment on or before the 1st, or enforce a clearly defined late fee after a 3–5 day grace period. This is a lease design fix, not a tenant management fix.

- **Require ACH auto-pay for new leases.** Check, ACH, and Zelle are split almost equally at 34.3%, 33.1%, and 32.6%. Standardizing on ACH auto-pay would reduce payment processing overhead, improve timing consistency, and eliminate manual reminders — directly addressing the late payment pattern with a structural solution.

- **Implement a security deposit of at least 1.5 months' rent with documented exit conditions.** Angie Henderson's $3,969 uncollected balance and Allison Hill's $1,732 gap represent the portfolio's primary loss events. At Angie's rate of $960/month, a 1.5-month deposit ($1,440) would have partially covered the shortfall; 2 months ($1,920) would have covered it fully with margin.

- **Add annual rent escalation clauses to future leases.** Rent growth of 48.9% over 15 years is solid but is currently captured only at turnover — not during tenancy. A 3% annual escalation clause, or CPI-linked adjustment, would compound appreciation between turnovers and reduce the financial pressure to raise rent aggressively at renewal.

- **Build a $9,000–$10,000 maintenance reserve fund.** The three high-expense years averaged $8,613 against an overall annual expense average of ~$6,064. A dedicated reserve — funded by setting aside a fixed monthly amount — would smooth cash flow across the portfolio's life cycle and reduce reliance on operating income to cover unexpected repair events.

- **Build a days-past-due calculation into the SQL analytics layer.** The current schema supports a clean join between `payments` and `invoices` on `invoice_id`. Adding a computed `days_late` field per payment would enable monthly aging analysis, surface late payment trends in real time, and provide data to support lease renegotiation conversations with tenants who chronically pay late.

---

## Tools Used

- PostgreSQL 17 (database layer)
- Docker & Docker Compose (containerized environment)
- pgAdmin 4 (database management UI)
- SQL (KPI analytics layer)
- Power BI (financial dashboard)
- Python (data validation and pipeline modeling)
