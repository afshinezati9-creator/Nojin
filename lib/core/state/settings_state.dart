import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/settings_repository.dart';
import 'nojin_providers.dart';

final settingsStateProvider =
    AsyncNotifierProvider<SettingsStateNotifier, Map<String, String>>(
  SettingsStateNotifier.new,
);

class SettingsStateNotifier extends AsyncNotifier<Map<String, String>> {
  Future<Map<String, String>> _readAll() async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    final rows = await repository.readAll();
    return {
      for (final row in rows) row.key: row.value,
    };
  }

  @override
  Future<Map<String, String>> build() => _readAll();

  Future<void> setValue(String key, String value) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(settingsRepositoryProvider.future);
      await repository.write(key, value);
      return _readAll();
    });
  }

  Future<void> remove(String key) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(settingsRepositoryProvider.future);
      await repository.delete(key);
      return _readAll();
    });
  }
}
