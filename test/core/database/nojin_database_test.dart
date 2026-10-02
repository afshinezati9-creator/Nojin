import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nojin/core/database/nojin_database.dart';
import 'package:nojin/core/database/repositories/settings_repository.dart';

void main() {
  late NojinDatabase database;

  setUp(() async {
    database = await NojinDatabase.fromConnection(
      DatabaseConnection.fromExecutor(NativeDatabase.memory()),
    );
  });

  tearDown(() => database.close());

  test('creates version 3 schema and indexes', () async {
    expect(await database.schemaVersion(), 3);
    expect(await database.isHealthy(), isTrue);

    final tables = await database.connection.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' ORDER BY name",
      [],
    );

    expect(
      tables.map((row) => row['name']).toList(),
      containsAll(<Object?>[
        'app_settings',
        'notes',
        'finance_accounts',
        'finance_transactions',
        'planning_items',
        'info_items',
        'nojin_meta',
        'note_media',
      ]),
    );

    final indexes = await database.connection.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'index' "
      "AND name LIKE '%_idx' ORDER BY name",
      [],
    );

    expect(indexes.length, 12);
  });

  test('settings repository persists and updates values', () async {
    final repository = SettingsRepository(database);
    await repository.write('theme', 'dark');
    expect(await repository.read('theme'), 'dark');
    await repository.write('theme', 'light');
    expect(await repository.read('theme'), 'light');
    await repository.delete('theme');
    expect(await repository.read('theme'), isNull);
  });

  test('settings SQL remains directly queryable', () async {
    await database.connection.runCustom(
      'INSERT INTO app_settings(key, value, updated_at) VALUES (?, ?, ?)',
      ['theme', 'dark', 1],
    );

    await database.connection.runCustom(
      'INSERT INTO app_settings(key, value, updated_at) VALUES (?, ?, ?) '
      'ON CONFLICT(key) DO UPDATE SET value = excluded.value',
      ['theme', 'light', 2],
    );

    final rows = await database.connection.runSelect(
      'SELECT value FROM app_settings WHERE key = ?',
      ['theme'],
    );

    expect(rows.single['value'], 'light');
  });

  test('transaction rolls back on failure', () async {
    expect(
      () => database.transaction((tx) async {
        await tx.runCustom(
          'INSERT INTO app_settings(key, value, updated_at) VALUES (?, ?, ?)',
          ['rollback', 'should-not-exist', 1],
        );
        throw StateError('forced rollback');
      }),
      throwsA(isA<StateError>()),
    );

    final rows = await database.connection.runSelect(
      'SELECT key FROM app_settings WHERE key = ?',
      ['rollback'],
    );
    expect(rows, isEmpty);
  });

  test('migrates version 2 finance accounts with Iranian fields', () async {
    final raw = NativeDatabase.memory();
    await raw.runCustom('CREATE TABLE nojin_meta (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)');
    await raw.runCustom(
      'CREATE TABLE finance_accounts (id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, '
      'account_type TEXT NOT NULL, currency TEXT NOT NULL DEFAULT "toman", balance INTEGER NOT NULL DEFAULT 0, '
      'is_archived INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)',
    );
    await raw.runCustom(
      'INSERT INTO nojin_meta(key, value) VALUES (?, ?)',
      ['schema_version', '2'],
    );

    final upgraded = await NojinDatabase.fromConnection(DatabaseConnection.fromExecutor(raw));
    expect(await upgraded.schemaVersion(), 3);
    final columns = await upgraded.connection.runSelect('PRAGMA table_info(finance_accounts)', []);
    final names = columns.map((row) => row['name']).toList();
    expect(names, containsAll(<Object?>['bank_name', 'account_number', 'card_number', 'sheba']));
    await upgraded.close();
    database = await NojinDatabase.fromConnection(
      DatabaseConnection.fromExecutor(NativeDatabase.memory()),
    );
  });
