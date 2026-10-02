# NOJÎN — Phase 15 Status

## Installments — Completed

Phase 15 adds a local-first installment engine to the Finance domain.

### Delivered

- Installment plans with total amount, installment count, currency and interval.
- Automatic schedule generation with monthly date calculation.
- Last-installment remainder handling so scheduled amounts sum exactly to the total.
- Jalali/Persian date presentation through the existing Iranian core.
- Per-installment status:
  - پرداخت‌شده
  - معوق
  - در انتظار
- Payment flow connected to an existing active finance account.
- Currency safety: installment and payment account must use the same currency.
- Paying an installment creates a real expense transaction and updates the account balance atomically.
- Payment stores the resulting transaction id and payment timestamp.
- Responsive installment section integrated into the Finance page.
- Drift schema migration from v3 to v4.
- Repository and migration tests for schedule generation, overdue state, payment accounting and currency mismatch.

### Persistence

Added:

- `finance_installment_plans`
- `finance_installments`

Schema version: **4**

### Boundaries

Debt/receivable relationships, creditors/debtors and broader lending semantics remain in Phase 16. Financial goals and emergency funds remain in Phase 17.

### Testing policy

GitHub Actions/CI was not added. Flutter tests/analyze must be run locally on Windows with the project's Flutter SDK and Chrome/Android targets.
