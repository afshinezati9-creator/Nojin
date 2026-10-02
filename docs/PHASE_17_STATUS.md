# NOJÎN — Phase 17 Status

## Goals / Emergency Fund — Completed

Phase 17 adds a unified financial-goal tracker with a dedicated emergency-fund type.

### Delivered

- Financial goals with a target amount.
- Dedicated **صندوق اضطراری** goal type.
- Toman / Rial support.
- Current saved amount and remaining amount.
- Progress percentage with capped visual progress.
- Optional Jalali-display deadline.
- Active, completed and overdue states.
- Savings contribution history.
- Withdrawal history.
- Atomic goal balance updates with entry creation/deletion.
- Validation against withdrawals larger than the current goal balance.
- Responsive Finance UI.
- Goal details with progress and history.
- Drift schema migration from v5 to v6.
- Repository, domain and migration tests.

### Persistence

Added:

- `finance_goals`
- `finance_goal_entries`

Schema version: **6**

### Accounting boundary

Goal entries are currently an **earmarked savings tracker** and do not create income/expense transactions or alter bank-account balances. This keeps financial goals separate from cash-flow accounting until a dedicated transfer/earmarking model is introduced.

### Boundaries

Planning starts in Phase 18. Calendar Engine remains Phase 20.

### Testing policy

No GitHub Actions/CI was added. Flutter analyze/test must be run locally on Windows with the project's Flutter SDK and Chrome/Android targets.
