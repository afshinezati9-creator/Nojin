import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/nojin_database_provider.dart';
import 'notes_repository.dart';

final notesRepositoryProvider = FutureProvider<NotesRepository>((ref) async {
  final database = await ref.watch(nojinDatabaseProvider.future);
  return NotesRepository(database);
});
