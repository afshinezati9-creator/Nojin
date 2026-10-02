import 'dart:math';

import '../../../core/database/nojin_database.dart';
import '../domain/note.dart';

class NotesRepository {
  NotesRepository(this._database);

  final NojinDatabase _database;

  Future<List<Note>> list({
    String query = '',
    NoteCategory? category,
    bool includeArchived = false,
    bool pinnedOnly = false,
    NoteSort sort = NoteSort.updatedDesc,
  }) async {
    final where = <String>[];
    final args = <Object?>[];

    if (!includeArchived) where.add('is_archived = 0');
    if (pinnedOnly) where.add('is_pinned = 1');
    if (category != null) {
      where.add('category = ?');
      args.add(category.key);
    }

    final normalizedQuery = query.trim();
    if (normalizedQuery.isNotEmpty) {
      where.add('(title LIKE ? OR content LIKE ?)');
      final pattern = '%' + normalizedQuery + '%';
      args
        ..add(pattern)
        ..add(pattern);
    }

    final orderBy = switch (sort) {
      NoteSort.updatedDesc => 'is_pinned DESC, updated_at DESC',
      NoteSort.createdDesc => 'is_pinned DESC, created_at DESC',
      NoteSort.pinnedFirst => 'is_pinned DESC, updated_at DESC',
    };

    final sql = StringBuffer(
      'SELECT id, title, content, category, is_pinned, is_archived, '
      'created_at, updated_at FROM notes',
    );
    if (where.isNotEmpty) {
      sql.write(' WHERE ');
      sql.write(where.join(' AND '));
    }
    sql.write(' ORDER BY ' + orderBy);

    final rows = await _database.connection.runSelect(sql.toString(), args);
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<Note?> getById(String id) async {
    final rows = await _database.connection.runSelect(
      'SELECT id, title, content, category, is_pinned, is_archived, '
      'created_at, updated_at FROM notes WHERE id = ? LIMIT 1',
      [id],
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Future<Note> create({
    required String title,
    required String content,
    required NoteCategory category,
  }) async {
    final now = DateTime.now().toUtc();
    final note = Note(
      id: _newId(),
      title: title.trim().isEmpty ? 'یادداشت بدون عنوان' : title.trim(),
      content: content,
      category: category,
      isPinned: false,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
    await _insert(note);
    return note;
  }

  Future<void> update(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now().toUtc());
    await _database.connection.runCustom(
      'UPDATE notes SET title = ?, content = ?, category = ?, '
      'is_pinned = ?, is_archived = ?, updated_at = ? WHERE id = ?',
      [
        updated.title,
        updated.content,
        updated.category.key,
        updated.isPinned ? 1 : 0,
        updated.isArchived ? 1 : 0,
        updated.updatedAt.millisecondsSinceEpoch,
        updated.id,
      ],
    );
  }

  Future<void> setPinned(String id, bool value) {
    return _database.connection.runCustom(
      'UPDATE notes SET is_pinned = ?, updated_at = ? WHERE id = ?',
      [value ? 1 : 0, DateTime.now().toUtc().millisecondsSinceEpoch, id],
    );
  }

  Future<void> setArchived(String id, bool value) {
    return _database.connection.runCustom(
      'UPDATE notes SET is_archived = ?, updated_at = ? WHERE id = ?',
      [value ? 1 : 0, DateTime.now().toUtc().millisecondsSinceEpoch, id],
    );
  }

  Future<void> delete(String id) {
    return _database.connection.runCustom('DELETE FROM notes WHERE id = ?', [id]);
  }

  Future<void> _insert(Note note) {
    return _database.connection.runCustom(
      'INSERT INTO notes(id, title, content, category, is_pinned, is_archived, '
      'created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        note.id,
        note.title,
        note.content,
        note.category.key,
        note.isPinned ? 1 : 0,
        note.isArchived ? 1 : 0,
        note.createdAt.millisecondsSinceEpoch,
        note.updatedAt.millisecondsSinceEpoch,
      ],
    );
  }

  Note _fromRow(Map<String, Object?> row) {
    return Note(
      id: row['id'].toString(),
      title: row['title'].toString(),
      content: row['content'].toString(),
      category: NoteCategoryX.fromKey(row['category'].toString()),
      isPinned: row['is_pinned'] == 1,
      isArchived: row['is_archived'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        int.parse(row['created_at'].toString()),
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        int.parse(row['updated_at'].toString()),
        isUtc: true,
      ),
    );
  }

  String _newId() {
    final now = DateTime.now().toUtc().microsecondsSinceEpoch;
    final random = Random().nextInt(1 << 32);
    return now.toString() + '-' + random.toRadixString(16);
  }
}

enum NoteSort { updatedDesc, createdDesc, pinnedFirst }
