import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/database/nojin_database.dart';
import '../../../lib/features/notes/data/notes_repository.dart';
import '../../../lib/features/notes/domain/note.dart';

void main() {
  late NojinDatabase database;
  late NotesRepository repository;

  setUp(() async {
    database = await NojinDatabase.fromConnection(
      DatabaseConnection.fromExecutor(NativeDatabase.memory()),
    );
    repository = NotesRepository(database);
  });

  tearDown(() => database.close());

  test('creates and reads a note', () async {
    final note = await repository.create(
      title: 'ایده نو',
      content: 'متن یادداشت',
      category: NoteCategory.ideas,
    );

    final loaded = await repository.getById(note.id);
    expect(loaded?.title, 'ایده نو');
    expect(loaded?.category, NoteCategory.ideas);
    expect(loaded?.content, 'متن یادداشت');
  });

  test('filters by category, pin and archive', () async {
    final work = await repository.create(
      title: 'کار',
      content: 'جلسه',
      category: NoteCategory.work,
    );
    final personal = await repository.create(
      title: 'شخصی',
      content: 'خرید',
      category: NoteCategory.personal,
    );

    await repository.setPinned(work.id, true);
    await repository.setArchived(personal.id, true);

    expect((await repository.list(category: NoteCategory.work)).single.id, work.id);
    expect((await repository.list(pinnedOnly: true)).single.id, work.id);
    expect((await repository.list()).length, 1);
    expect((await repository.list(includeArchived: true)).length, 2);
  });

  test('searches title and content', () async {
    await repository.create(
      title: 'جلسه هفتگی',
      content: 'برنامه فروش',
      category: NoteCategory.work,
    );
    await repository.create(
      title: 'مطالعه',
      content: 'کتاب مدیریت',
      category: NoteCategory.study,
    );

    expect((await repository.list(query: 'فروش')).single.title, 'جلسه هفتگی');
    expect((await repository.list(query: 'مدیریت')).single.title, 'مطالعه');
  });

  test('updates and deletes a note', () async {
    final note = await repository.create(
      title: 'قدیمی',
      content: 'متن',
      category: NoteCategory.general,
    );
    await repository.update(
      note.copyWith(title: 'جدید', category: NoteCategory.study),
    );

    final updated = await repository.getById(note.id);
    expect(updated?.title, 'جدید');
    expect(updated?.category, NoteCategory.study);

    await repository.delete(note.id);
    expect(await repository.getById(note.id), isNull);
  });
}
