import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _subscription;
  final BytesBuilder _buffer = BytesBuilder();
  bool _recording = false;

  bool get isRecording => _recording;

  Future<bool> start() async {
    if (_recording) return true;
    if (!await _recorder.hasPermission()) return false;
    _buffer.clear();
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 44100,
        numChannels: 1,
      ),
    );
    _subscription = stream.listen(_buffer.add);
    _recording = true;
    return true;
  }

  Future<Uint8List?> stop() async {
    if (!_recording) return null;
    await _subscription?.cancel();
    _subscription = null;
    await _recorder.stop();
    _recording = false;
    final bytes = _buffer.takeBytes();
    return bytes.isEmpty ? null : Uint8List.fromList(bytes);
  }

  Future<void> cancel() async {
    await _subscription?.cancel();
    _subscription = null;
    await _recorder.cancel();
    _recording = false;
    _buffer.clear();
  }

  Future<void> dispose() async {
    await cancel();
    _recorder.dispose();
  }
}
