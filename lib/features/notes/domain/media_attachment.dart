import 'dart:typed_data';

enum MediaType { image, video, audio, file }

extension MediaTypeX on MediaType {
  String get key => name;
  String get label => switch (this) {
    MediaType.image => 'تصویر',
    MediaType.video => 'ویدئو',
    MediaType.audio => 'صوت',
    MediaType.file => 'فایل',
  };

  static MediaType fromKey(String value) => MediaType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => MediaType.file,
  );
}

class MediaAttachment {
  const MediaAttachment({
    required this.id,
    required this.noteId,
    required this.type,
    required this.fileName,
    required this.mimeType,
    required this.bytes,
    required this.sizeBytes,
    required this.createdAt,
    this.durationMs,
  });

  final String id;
  final String noteId;
  final MediaType type;
  final String fileName;
  final String mimeType;
  final Uint8List bytes;
  final int sizeBytes;
  final DateTime createdAt;
  final int? durationMs;

  bool get isImage => type == MediaType.image;
  bool get isVideo => type == MediaType.video;
  bool get isAudio => type == MediaType.audio;
  bool get isFile => type == MediaType.file;
}
