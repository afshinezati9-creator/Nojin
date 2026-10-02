# NOJÎN — Phase 07 Status

## Local Database

Phase 07 establishes the first real local persistence layer for NOJÎN.

### Technology

- Drift 2.35.1
- drift_flutter 0.3.1
- SQLite on native platforms
- Drift WASM + browser storage on Flutter Web
- No code-generation dependency in the runtime layer

Drift is used as the cross-platform SQL connection layer. The schema and migrations are explicit in lib/core/database/, so the foundation remains easy to inspect and does not block the app on generated files.

### Database structure

Schema version: 1

Core tables:

- app_settings
- notes
- finance_accounts
- finance_transactions
- planning_items
- info_items

Indexes are defined for the main list/filter/sort access paths.

### Migration and integrity

- nojin_meta stores the schema version.
- Database initialization creates the schema only when the database is new.
- Future versions must add an explicit migration branch.
- Opening a database with a newer unknown schema version fails instead of silently modifying data.
- isHealthy() runs SQLite integrity_check.
- Transactions use a real Drift TransactionExecutor and roll back on failure.
- clearAllData() is provided for controlled reset/testing.

### Repository layer

SettingsRepository is the first concrete repository. Feature repositories will be added with their corresponding feature phases rather than coupling the UI directly to SQL.

### Riverpod

nojinDatabaseProvider exposes the database as an async dependency and closes the connection when the provider is disposed.

### Web

Drift Web requires two version-compatible runtime assets:

- web/sqlite3.wasm
- web/drift_worker.js

Run the Windows PowerShell helper from the repository root:

    powershell -ExecutionPolicy Bypass -File .\tool\setup_drift_web.ps1

Then:

    flutter pub get
    flutter test
    flutter run -d chrome

For Android/Windows native development, the web assets are not required.

### Scope boundary

This phase does not implement:

- Notes CRUD UI
- Rich editor
- Finance business rules
- Planning algorithms
- Info Vault UI
- global state architecture

Those remain in their roadmap phases.

### Validation

test/core/database/nojin_database_test.dart covers:

- schema creation
- schema version
- index creation
- integrity check
- persistence/update behavior
- transaction rollback

The current execution environment does not contain the Flutter/Dart toolchain, so flutter analyze and flutter test cannot truthfully be reported as executed here. The test suite is committed for local Windows validation.
