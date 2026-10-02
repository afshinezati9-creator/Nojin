import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'nojin_database.dart';

final nojinDatabaseProvider = FutureProvider<NojinDatabase>((ref) async {
  final database = await NojinDatabase.open();
  ref.onDispose(() {
    database.close();
  });
  return database;
});
