import '../nojin_database.dart';

class SettingsRepository {
  SettingsRepository(this._database);

  final NojinDatabase _database;

  Future<String?> read(String key) async {
    final rows = await _database.connection.runSelect(
      'SELECT value FROM app_settings WHERE key = ? LIMIT 1',
      [key],
    );
    if (rows.isEmpty) return null;
    return rows.first['value']?.toString();
  }

  Future<Map<String, String>> readAll() async {
    final rows = await _database.connection.runSelect(
      'SELECT key, value FROM app_settings ORDER BY key ASC',
      [],
    );
    return {
      for (final row in rows)
        row['key'].toString(): row['value'].toString(),
    };
  }

  Future<void> write(String key, String value) {
    return _database.connection.runCustom(
      'INSERT INTO app_settings(key, value, updated_at) VALUES (?, ?, ?) '
      'ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = excluded.updated_at',
      [
        key,
        value,
        DateTime.now().toUtc().millisecondsSinceEpoch,
      ],
    );
  }

  Future<void> delete(String key) {
    return _database.connection.runCustom(
      'DELETE FROM app_settings WHERE key = ?',
      [key],
    );
  }
}
