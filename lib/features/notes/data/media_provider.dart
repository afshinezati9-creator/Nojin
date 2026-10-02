import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/nojin_database_provider.dart';
import 'media_repository.dart';

final mediaRepositoryProvider = FutureProvider<MediaRepository>((ref) async {
  final database = await ref.watch(nojinDatabaseProvider.future);
  return MediaRepository(database);
});
