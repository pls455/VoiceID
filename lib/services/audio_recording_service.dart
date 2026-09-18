import 'package:flutter/services.dart';

class AudioRecordingService {
  static const _channel = MethodChannel('voiceid/audio');
  bool _recording = false;

  bool get isRecording => _recording;

  Future<void> start() async {
    await _channel.invokeMethod('start');
    _recording = true;
  }

  Future<void> stop() async {
    await _channel.invokeMethod('stop');
    _recording = false;
  }

  Future<double> getLevel() async {
    final value = await _channel.invokeMethod<num>('level');
    return value?.toDouble() ?? 0.0;
  }
}
