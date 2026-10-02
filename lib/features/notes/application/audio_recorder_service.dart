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
    return bytes.isEmpty ? null : _pcmToWav(Uint8List.fromList(bytes));
  }

  Uint8List _pcmToWav(Uint8List pcm) {
    const sampleRate = 44100;
    const channels = 1;
    const bitsPerSample = 16;
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final blockAlign = channels * bitsPerSample ~/ 8;
    final dataLength = pcm.length;
    final output = ByteData(44 + dataLength);
    void writeString(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        output.setUint8(offset + i, value.codeUnitAt(i));
      }
    }
    writeString(0, 'RIFF');
    output.setUint32(4, 36 + dataLength, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    output.setUint32(16, 16, Endian.little);
    output.setUint16(20, 1, Endian.little);
    output.setUint16(22, channels, Endian.little);
    output.setUint32(24, sampleRate, Endian.little);
    output.setUint32(28, byteRate, Endian.little);
    output.setUint16(32, blockAlign, Endian.little);
    output.setUint16(34, bitsPerSample, Endian.little);
    writeString(36, 'data');
    output.setUint32(40, dataLength, Endian.little);
    for (var i = 0; i < pcm.length; i++) {
      output.setUint8(44 + i, pcm[i]);
    }
    return output.buffer.asUint8List();
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
