import 'dart:math';
import 'dart:typed_data';

import '../../../core/database/nojin_database.dart';
import '../domain/media_attachment.dart';

class MediaRepository {
  MediaRepository(this._database);

  final NojinDatabase _database;

  Future<MediaAttachment> add({
    required String noteId,
    required MediaType type,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
    int? durationMs,
  }) async {
    if (bytes.isEmpty) throw ArgumentError('رسانه خالی است.');
    if (bytes.length > MediaLimits.maxBytes) {
      throw ArgumentError('حجم فایل از سقف مجاز نوژین بیشتر است.');
    }
    final now = DateTime.now().toUtc();
    final item = MediaAttachment(
      id: _newId(),
      noteId: noteId,
      type: type,
      fileName: fileName.trim().isEmpty ? 'فایل' : fileName.trim(),
      mimeType: mimeType,
      bytes: bytes,
      sizeBytes: bytes.length,
      durationMs: durationMs,
      createdAt: now,
    );
    await _database.connection.runCustom(
      'INSERT INTO note_media(id, note_id, media_type, file_name, mime_type, bytes, size_bytes, duration_ms, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [item.id, item.noteId, item.type.key, item.fileName, item.mimeType, item.bytes, item.sizeBytes, item.durationMs, item.createdAt.millisecondsSinceEpoch],
    );
    return item;
  }

  Future<List<MediaAttachment>> listByNote(String noteId) async {
    final rows = await _database.connection.runSelect(
      'SELECT id, note_id, media_type, file_name, mime_type, bytes, size_bytes, duration_ms, created_at FROM note_media WHERE note_id = ? ORDER BY created_at ASC',
      [noteId],
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<MediaAttachment?> getById(String id) async {
    final rows = await _database.connection.runSelect(
      'SELECT id, note_id, media_type, file_name, mime_type, bytes, size_bytes, duration_ms, created_at FROM note_media WHERE id = ? LIMIT 1',
      [id],
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Future<void> delete(String id) {
    return _database.connection.runCustom('DELETE FROM note_media WHERE id = ?', [id]);
  }

  Future<void> deleteForNote(String noteId) {
    return _database.connection.runCustom('DELETE FROM note_media WHERE note_id = ?', [noteId]);
  }

  MediaAttachment _fromRow(Map<String, Object?> row) {
    final raw = row['bytes'];
    final bytes = raw is Uint8List
        ? raw
        : Uint8List.fromList((raw as List).cast<int>());
    return MediaAttachment(
      id: row['id'].toString(),
      noteId: row['note_id'].toString(),
      type: MediaTypeX.fromKey(row['media_type'].toString()),
      fileName: row['file_name'].toString(),
      mimeType: row['mime_type'].toString(),
      bytes: bytes,
      sizeBytes: int.parse(row['size_bytes'].toString()),
      durationMs: row['duration_ms'] == null ? null : int.tryParse(row['duration_ms'].toString()),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        int.parse(row['created_at'].toString()),
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

abstract final class MediaLimits {
  static const maxBytes = 25 * 1024 * 1024;
}
