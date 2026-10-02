import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nojin/core/database/nojin_database.dart';
import 'package:nojin/features/notes/data/media_repository.dart';
import 'package:nojin/features/notes/domain/media_attachment.dart';

void main() {
  late NojinDatabase database;
  late MediaRepository repository;

  setUp(() async {
    database = await NojinDatabase.fromConnection(
      DatabaseConnection.fromExecutor(NativeDatabase.memory()),
    );
    repository = MediaRepository(database);
    await database.connection.runCustom(
      'INSERT INTO notes(id, title, content, category, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
      ['note-1', 'یادداشت', '', 'general', 1, 1],
    );
  });

  tearDown(() => database.close());

  test('stores and reads binary media metadata', () async {
    final item = await repository.add(
      noteId: 'note-1',
      type: MediaType.image,
      fileName: 'photo.png',
      mimeType: 'image/png',
      bytes: Uint8List.fromList([1, 2, 3, 4]),
    );

    final loaded = await repository.getById(item.id);
    expect(loaded, isNotNull);
    expect(loaded!.fileName, 'photo.png');
    expect(loaded.bytes, orderedEquals([1, 2, 3, 4]));
    expect(loaded.type, MediaType.image);
  });

  test('lists and deletes note media', () async {
    await repository.add(
      noteId: 'note-1',
      type: MediaType.file,
      fileName: 'sample.pdf',
      mimeType: 'application/pdf',
      bytes: Uint8List.fromList([8, 9]),
    );
    expect((await repository.listByNote('note-1')).length, 1);
    await repository.deleteForNote('note-1');
    expect(await repository.listByNote('note-1'), isEmpty);
  });
}
