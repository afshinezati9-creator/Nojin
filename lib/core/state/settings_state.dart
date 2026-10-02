import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/settings_repository.dart';

final settingsStateProvider =
    AsyncNotifierProvider<SettingsStateNotifier, Map<String, String>>(
  SettingsStateNotifier.new,
);

class SettingsStateNotifier extends AsyncNotifier<Map<String, String>> {
  SettingsRepository get _repository =>
      ref.read(settingsRepositoryProvider).requireValue;

  @override
  Future<Map<String, String>> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    final rows = await repository.readAll();
    return {
      for (final row in rows) row.key: row.value,
    };
  }

  Future<void> setValue(String key, String value) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.write(key, value);
      return build();
    });
  }

  Future<void> remove(String key) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.delete(key);
      return build();
    });
  }
}
