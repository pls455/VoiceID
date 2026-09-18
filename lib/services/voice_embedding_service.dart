import 'package:flutter/services.dart';

class VoiceEmbeddingService {
  static const _channel = MethodChannel('voiceid/audio');

  Future<List<double>> embedCurrent() async {
    final result = await _channel.invokeMethod<List<dynamic>>('embedCurrent');
    if (result == null || result.isEmpty) {
      throw StateError('لم يتم التقاط عينة صوتية كافية');
    }
    return result.map((e) => (e as num).toDouble()).toList(growable: false);
  }

  Future<bool> modelReady() async {
    return await _channel.invokeMethod<bool>('modelReady') ?? false;
  }
}
