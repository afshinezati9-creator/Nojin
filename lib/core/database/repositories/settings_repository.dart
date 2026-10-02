import 'package:drift/drift.dart';

import '../nojin_database.dart';

class SettingsRepository {
  SettingsRepository(this._database);

  final NojinDatabase _database;

  Future<String?> read(String key) async {
    final row = await (_database.select(_database.appSettings)
          ..where((table) => table.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> write(String key, String value) {
    return _database.into(_database.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> delete(String key) {
    return (_database.delete(_database.appSettings)
          ..where((table) => table.key.equals(key)))
        .go();
  }

  Stream<List<AppSetting>> watchAll() {
    return (_database.select(_database.appSettings)
          ..orderBy([(table) => OrderingTerm.asc(table.key)]))
        .watch();
  }
}
