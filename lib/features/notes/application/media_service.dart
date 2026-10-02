import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../domain/media_attachment.dart';

class MediaDraft {
  const MediaDraft({
    required this.tempId,
    required this.type,
    required this.fileName,
    required this.mimeType,
    required this.bytes,
    this.durationMs,
  });

  final String tempId;
  final MediaType type;
  final String fileName;
  final String mimeType;
  final Uint8List bytes;
  final int? durationMs;
}

class MediaService {
  MediaService({ImagePicker? imagePicker}) : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<MediaDraft?> pickImage() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 92);
    return file == null ? null : _fromXFile(file, MediaType.image);
  }

  Future<MediaDraft?> pickVideo() async {
    final file = await _imagePicker.pickVideo(source: ImageSource.gallery);
    return file == null ? null : _fromXFile(file, MediaType.video);
  }

  Future<MediaDraft?> pickFile() async {
    final files = await FilePicker.pickFiles(type: FileType.any);
    if (files.isEmpty) return null;
    final file = files.first;
    final bytes = await file.readAsBytes();
    final name = file.name;
    final mime = lookupMimeType(name, headerBytes: bytes.take(32).toList()) ?? 'application/octet-stream';
    return MediaDraft(
      tempId: _id(),
      type: _typeForMime(mime),
      fileName: name,
      mimeType: mime,
      bytes: bytes,
    );
  }

  MediaDraft fromRecordedBytes({
    required Uint8List bytes,
    String fileName = 'ضبط-صوت.wav',
    String mimeType = 'audio/wav',
  }) {
    return MediaDraft(
      tempId: _id(),
      type: MediaType.audio,
      fileName: fileName,
      mimeType: mimeType,
      bytes: bytes,
    );
  }

  Future<MediaDraft> _fromXFile(XFile file, MediaType type) async {
    final bytes = await file.readAsBytes();
    final mime = lookupMimeType(file.name, headerBytes: bytes.take(32).toList()) ??
        (type == MediaType.image ? 'image/*' : 'video/*');
    return MediaDraft(
      tempId: _id(),
      type: type,
      fileName: file.name,
      mimeType: mime,
      bytes: bytes,
    );
  }

  MediaType _typeForMime(String mime) {
    if (mime.startsWith('image/')) return MediaType.image;
    if (mime.startsWith('video/')) return MediaType.video;
    if (mime.startsWith('audio/')) return MediaType.audio;
    return MediaType.file;
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
}
