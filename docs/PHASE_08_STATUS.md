# NOJÎN — Phase 08 Status

## State Architecture

Phase 08 establishes the application-wide state dependency flow without implementing Notes, Finance, Planning, or Info business logic.

### Flow

```
UI / Presentation
        ↓
Riverpod State
        ↓
UseCase / Domain Contract
        ↓
Repository
        ↓
Local Database
```

The database provider remains the infrastructure entry point. Repositories are resolved through Riverpod providers instead of being constructed inside widgets.

### Added

- `lib/core/state/nojin_use_case.dart`
  - explicit async/sync use-case contracts
- `lib/core/state/nojin_providers.dart`
  - Riverpod repository dependency providers
- `lib/core/state/settings_state.dart`
  - a small cross-cutting reference implementation showing AsyncNotifier → Repository → Drift
- `test/core/state/nojin_state_architecture_test.dart`
  - verifies the use-case contract independently

### Repository dependency flow

`settingsRepositoryProvider` depends on `nojinDatabaseProvider`.

This keeps UI code unaware of Drift connections and makes repository dependencies replaceable in tests through Riverpod overrides.

### State rules

1. Widgets must not access Drift directly.
2. Widgets must not construct repositories.
3. Repositories own persistence access and data translation.
4. Use cases own business operations when a feature needs domain behavior.
5. Riverpod owns application state and dependency wiring.
6. Feature phases should add their own state/controllers rather than putting domain state into a global singleton.
7. Local persistence remains the default source of truth.

### Scope boundary

This phase deliberately does not implement:

- Notes state or CRUD
- Finance state or calculations
- Planning state
- Info Vault state
- global search state
- sync/cloud state

Those belong to their respective feature phases.

### Validation

The committed state architecture includes a framework-independent use-case contract test.

Flutter analyzer/test execution still needs to be performed in the user's local Windows/Flutter environment, consistent with the project workflow. No GitHub Actions workflow is introduced.
