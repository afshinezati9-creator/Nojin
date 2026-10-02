import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/nojin_database.dart';
import '../database/nojin_database_provider.dart';
import '../database/repositories/settings_repository.dart';

final settingsRepositoryProvider = FutureProvider<SettingsRepository>((ref) async {
  final database = await ref.watch(nojinDatabaseProvider.future);
  return SettingsRepository(database);
});
