# DAX measures (paste into Power BI)

> Assumes table names: Invoices_Table, Payments_Table, Expenses_Table. Adjust names if different.

## Core totals
Rent Billed :=
SUM ( Invoices_Table[rent_amount] )

Rent Collected :=
SUM ( Payments_Table[amount_paid] )

Total Expenses :=
SUM ( Expenses_Table[amount] )

Outstanding AR :=
VAR Billed = [Rent Billed]
VAR Collected = [Rent Collected]
RETURN Billed - Collected

Collection Rate :=
DIVIDE ( [Rent Collected], [Rent Billed] )

NOI :=
[Rent Collected] - [Total Expenses]

## Timeliness (requires a calculated column or a measure using LOOKUPVALUE)
-- Recommended: create a calculated column on Invoices for FirstPaymentDate
FirstPaymentDate :=
CALCULATE (
    MIN ( Payments_Table[payment_date] ),
    FILTER ( Payments_Table, Payments_Table[invoice_id] = Invoices_Table[invoice_id] )
)

Days Late :=
DATEDIFF ( Invoices_Table[due_date], Invoices_Table[FirstPaymentDate], DAY )

On-Time (<= 5 days) Count :=
CALCULATE (
    DISTINCTCOUNT ( Invoices_Table[invoice_id] ),
    FILTER ( Invoices_Table, NOT ISBLANK ( Invoices_Table[FirstPaymentDate] ) && Invoices_Table[Days Late] <= 5 )
)

Paid Invoice Count :=
CALCULATE (
    DISTINCTCOUNT ( Invoices_Table[invoice_id] ),
    FILTER ( Invoices_Table, NOT ISBLANK ( Invoices_Table[FirstPaymentDate] ) )
)

On-Time Rate (<= 5 days) :=
DIVIDE ( [On-Time (<= 5 days) Count], [Paid Invoice Count] )

Avg Days Late :=
AVERAGEX (
    FILTER ( Invoices_Table, NOT ISBLANK ( Invoices_Table[Days Late] ) ),
    Invoices_Table[Days Late]
)

## AR Aging (as of selected date; fallback to today)
AsOfDate :=
COALESCE ( MAX ( 'Date'[Date] ), TODAY() )

AR 0-30 :=
VAR asof = [AsOfDate]
RETURN
SUMX (
    FILTER (
        Invoices_Table,
        Invoices_Table[status] = "Unpaid"
            && DATEDIFF ( Invoices_Table[due_date], asof, DAY ) <= 30
    ),
    Invoices_Table[rent_amount]
)

AR 31-60 :=
VAR asof = [AsOfDate]
RETURN
SUMX (
    FILTER (
        Invoices_Table,
        Invoices_Table[status] = "Unpaid"
            && DATEDIFF ( Invoices_Table[due_date], asof, DAY ) >= 31
            && DATEDIFF ( Invoices_Table[due_date], asof, DAY ) <= 60
    ),
    Invoices_Table[rent_amount]
)

AR 61-90 :=
VAR asof = [AsOfDate]
RETURN
SUMX (
    FILTER (
        Invoices_Table,
        Invoices_Table[status] = "Unpaid"
            && DATEDIFF ( Invoices_Table[due_date], asof, DAY ) >= 61
            && DATEDIFF ( Invoices_Table[due_date], asof, DAY ) <= 90
    ),
    Invoices_Table[rent_amount]
)

AR 90+ :=
VAR asof = [AsOfDate]
RETURN
SUMX (
    FILTER (
        Invoices_Table,
        Invoices_Table[status] = "Unpaid"
            && DATEDIFF ( Invoices_Table[due_date], asof, DAY ) > 90
    ),
    Invoices_Table[rent_amount]
)
