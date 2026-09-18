import '../ffi/audio_engine_ffi.dart';

class AudioRecordingService {
  final AudioEngineFfi engine;
  AudioRecordingService({AudioEngineFfi? engine}) : engine = engine ?? AudioEngineFfi();
  bool _recording = false;
  bool get isRecording => _recording;

  Future<void> start() async {
    final result = engine.start();
    if (result != 0) throw StateError('Native audio engine failed: $result');
    _recording = true;
  }

  Future<void> stop() async {
    engine.stop();
    _recording = false;
  }

  double get level => engine.level;
}
