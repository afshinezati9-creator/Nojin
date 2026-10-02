import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'nojin_schema.dart';

class NojinDatabase {
  NojinDatabase._(this.connection);
  final DatabaseConnection connection;

  static Future<NojinDatabase> open() async {
    final database = NojinDatabase._(driftDatabase(
      name: 'nojin',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ));
    await database._initialize();
    return database;
  }

  static Future<NojinDatabase> fromConnection(DatabaseConnection connection) async {
    final database = NojinDatabase._(connection);
    await database._initialize();
    return database;
  }

  Future<void> _initialize() async {
    await connection.runCustom('CREATE TABLE IF NOT EXISTS nojin_meta (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)');
    final rows = await connection.runSelect('SELECT value FROM nojin_meta WHERE key = ? LIMIT 1', ['schema_version']);
    final current = rows.isEmpty ? 0 : int.tryParse(rows.first['value']?.toString() ?? '') ?? 0;
    if (current == 0) {
      await transaction((tx) async {
        for (final sql in NojinSchema.createStatements) {
          await tx.runCustom(sql);
        }
      });
    } else if (current < NojinSchema.version) {
      await _upgrade(current, NojinSchema.version);
    } else if (current > NojinSchema.version) {
      throw StateError('Database version ' + current.toString() + ' is newer than app schema ' + NojinSchema.version.toString() + '.');
    }
    await connection.runCustom(
      'INSERT INTO nojin_meta(key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value',
      ['schema_version', NojinSchema.version.toString()],
    );
  }

  Future<void> _upgrade(int from, int to) async {
    await transaction((tx) async {
      for (var version = from + 1; version <= to; version++) {
        switch (version) {
          case 1:
            for (final sql in NojinSchema.createStatements) {
              await tx.runCustom(sql);
            }
            break;
          case 2:
            await tx.runCustom('CREATE TABLE note_media (id TEXT NOT NULL PRIMARY KEY, note_id TEXT NOT NULL, media_type TEXT NOT NULL, file_name TEXT NOT NULL, mime_type TEXT NOT NULL, bytes BLOB NOT NULL, size_bytes INTEGER NOT NULL, duration_ms INTEGER, created_at INTEGER NOT NULL)');
            await tx.runCustom('CREATE INDEX note_media_note_idx ON note_media(note_id, created_at)');
            break;
          case 3:
            await tx.runCustom('ALTER TABLE finance_accounts ADD COLUMN bank_name TEXT');
            await tx.runCustom('ALTER TABLE finance_accounts ADD COLUMN account_number TEXT');
            await tx.runCustom('ALTER TABLE finance_accounts ADD COLUMN card_number TEXT');
            await tx.runCustom('ALTER TABLE finance_accounts ADD COLUMN sheba TEXT');
            break;
          case 4:
            await tx.runCustom('CREATE TABLE finance_installment_plans (id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL, total_amount INTEGER NOT NULL, installment_amount INTEGER NOT NULL, installment_count INTEGER NOT NULL, currency TEXT NOT NULL DEFAULT "toman", first_due_at INTEGER NOT NULL, interval_months INTEGER NOT NULL DEFAULT 1, note TEXT NOT NULL DEFAULT "", created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)');
            await tx.runCustom('CREATE TABLE finance_installments (id TEXT NOT NULL PRIMARY KEY, plan_id TEXT NOT NULL, sequence INTEGER NOT NULL, due_at INTEGER NOT NULL, amount INTEGER NOT NULL, paid_at INTEGER, transaction_id TEXT)');
            await tx.runCustom('CREATE INDEX finance_installment_plans_due_idx ON finance_installment_plans(first_due_at)');
            await tx.runCustom('CREATE INDEX finance_installments_plan_due_idx ON finance_installments(plan_id, due_at)');
            await tx.runCustom('CREATE INDEX finance_installments_status_idx ON finance_installments(paid_at, due_at)');
            break;
          default:
            throw StateError('Missing migration for database version ' + version.toString() + '.');
        }
      }
    });
  }

  Future<T> transaction<T>(Future<T> Function(DatabaseConnection tx) action) async {
    final executor = connection.beginTransaction();
    final tx = connection.withExecutor(executor);
    try {
      final result = await action(tx);
      await executor.send();
      return result;
    } catch (_) {
      await executor.rollback();
      rethrow;
    }
  }

  Future<bool> isHealthy() async {
    final rows = await connection.runSelect('PRAGMA integrity_check', []);
    return rows.length == 1 && rows.first.values.first == 'ok';
  }

  Future<int> schemaVersion() async {
    final rows = await connection.runSelect('SELECT value FROM nojin_meta WHERE key = ? LIMIT 1', ['schema_version']);
    return rows.isEmpty ? 0 : int.tryParse(rows.first['value']?.toString() ?? '') ?? 0;
  }

  Future<void> clearAllData() async {
    await transaction((tx) async {
      for (final table in NojinSchema.tableNames.reversed) {
        await tx.runCustom('DELETE FROM ' + table);
      }
    });
  }

  Future<void> close() => connection.close();
}
