import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_recording_service.dart';
import '../services/voice_embedding_service.dart';
import '../repositories/voice_profile_repository.dart';
import '../ffi/recognition_ffi.dart';

class LiveRecognitionScreen extends StatefulWidget {
  const LiveRecognitionScreen({super.key});
  @override State<LiveRecognitionScreen> createState() => _LiveRecognitionScreenState();
}
class _LiveRecognitionScreenState extends State<LiveRecognitionScreen> {
  final audio = AudioRecordingService();
  final embedder = VoiceEmbeddingService();
  final repo = VoiceProfileRepository();
  final native = RecognitionFfi();
  Timer? timer;
  final Map<String,String> names = {};
  bool running = false, processing = false;
  String result = 'غير معروف';
  double similarity = 0, level = 0;

  Future<void> start() async {
    final profiles = await repo.all();
    native.clear();
    names.clear();
    for (final p in profiles) {
      native.addProfile(p.id, p.embedding);
      names[p.id] = p.name;
    }
    if (profiles.isEmpty) {
      setState(() => result = 'أضف شخصًا أولًا');
      return;
    }
    await audio.start();
    setState(() { running = true; result = 'استمع...'; });
    timer = Timer.periodic(const Duration(seconds: 2), (_) => recognize());
  }

  Future<void> recognize() async {
    if (!running || processing) return;
    processing = true;
    try {
      level = await audio.getLevel();
      final emb = await embedder.embedCurrent();
      final match = native.recognize(emb, threshold: 0.55);
      if (!mounted) return;
      setState(() {
        similarity = match.similarity;
        result = match.known ? (names[match.id] ?? match.id) : 'غير معروف';
      });
    } catch (_) {
      if (mounted) setState(() => result = 'جاري جمع عينة صوتية...');
    } finally {
      processing = false;
    }
  }

  Future<void> stop() async {
    timer?.cancel();
    timer = null;
    await audio.stop();
    if (mounted) setState(() { running = false; level = 0; });
  }

  @override void dispose() { timer?.cancel(); audio.stop(); super.dispose(); }

  @override Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('التعرف المباشر')),
      body: Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.record_voice_over, size: 72),
          const SizedBox(height: 24),
          Text(result, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Similarity: ' + similarity.toStringAsFixed(3)),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: level.clamp(0,1)),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: running ? stop : start,
            icon: Icon(running ? Icons.stop : Icons.mic),
            label: Text(running ? 'إيقاف' : 'بدء التعرف'),
          ),
        ]),
      )),
    ),
  );
}
