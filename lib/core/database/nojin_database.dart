import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'nojin_tables.dart';

part 'nojin_database.g.dart';

@DriftDatabase(
  tables: [
    AppSettings,
    Notes,
    FinanceAccounts,
    FinanceTransactions,
    PlanningItems,
    InfoItems,
  ],
)
class NojinDatabase extends _$NojinDatabase {
  NojinDatabase([QueryExecutor? executor])
      : super(
          executor ??
              driftDatabase(
                name: 'nojin',
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                ),
              ),
        );

  NojinDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Versioned schema changes will be added here as the product evolves.
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA synchronous = NORMAL');

          if (!details.wasCreated) {
            await customSelect('PRAGMA integrity_check').getSingle();
          }
        },
      );

  Future<bool> isHealthy() async {
    final result = await customSelect('PRAGMA integrity_check').getSingle();
    return result.data.values.first == 'ok';
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(infoItems).go();
      await delete(planningItems).go();
      await delete(financeTransactions).go();
      await delete(financeAccounts).go();
      await delete(notes).go();
      await delete(appSettings).go();
    });
  }
}
