# NOJÎN — Phase 16 Status

## Debt / Receivable — Completed

Phase 16 adds personal debt and receivable management on top of the existing Finance foundation.

### Delivered

- Two directions:
  - طلب از دیگران
  - بدهی به دیگران
- Person / counterparty name.
- Total amount with Toman/Rial support.
- Optional due date with Jalali display.
- Open, partially settled, overdue and settled states.
- Partial settlement.
- Settlement history.
- Settlement linked to a real finance account.
- Receivable settlement creates an income transaction.
- Payable settlement creates an expense transaction.
- Account balance and debt/receivable balance are updated in one database transaction.
- Currency mismatch protection.
- Archived-account protection.
- Responsive Finance UI integrated below installments.
- Drift schema migration from v4 to v5.
- Repository and migration tests.

### Persistence

Added:

- `finance_debts`
- `finance_debt_payments`

Schema version: **5**

### Boundaries

Installment schedules remain in Phase 15. Financial goals and emergency fund remain in Phase 17.

### Testing policy

No GitHub Actions/CI was added. Flutter analyze/test must be run locally on Windows with the project's Flutter SDK and Chrome/Android targets.
