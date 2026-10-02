import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'nojin_database.dart';

final nojinDatabaseProvider = Provider<NojinDatabase>((ref) {
  final database = NojinDatabase();
  ref.onDispose(database.close);
  return database;
});
