import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/audio_recording_service.dart';
import '../services/voice_embedding_service.dart';
import '../repositories/voice_profile_repository.dart';

class AddPersonScreen extends StatefulWidget {
  const AddPersonScreen({super.key});
  @override State<AddPersonScreen> createState() => _AddPersonScreenState();
}
class _AddPersonScreenState extends State<AddPersonScreen> {
  final name = TextEditingController();
  final audio = AudioRecordingService();
  final embedder = VoiceEmbeddingService();
  final repo = VoiceProfileRepository();
  final samples = <List<double>>[];
  bool recording = false, busy = false;
  String status = 'سجّل 3 عينات صوتية واضحة';

  Future<void> recordSample() async {
    if (recording || busy) return;
    setState(() { recording = true; status = 'تحدث بوضوح لمدة 3 إلى 5 ثوانٍ...'; });
    try {
      await audio.start();
      await Future.delayed(const Duration(seconds: 4));
      await audio.stop();
      final embedding = await embedder.embedCurrent();
      samples.add(embedding);
      setState(() { recording = false; status = 'تمت العينة ' + samples.length.toString() + '/3'; });
    } catch (e) {
      try { await audio.stop(); } catch (_) {}
      setState(() { recording = false; status = 'فشلت العينة: ' + e.toString(); });
    }
  }

  Future<void> save() async {
    final n = name.text.trim();
    if (n.isEmpty || samples.length < 3) return;
    setState(() => busy = true);
    try {
      final dim = samples.first.length;
      final avg = List<double>.filled(dim, 0);
      for (final sample in samples) {
        if (sample.length != dim) throw StateError('Embedding dimensions differ');
        for (var i = 0; i < dim; i++) avg[i] += sample[i];
      }
      for (var i = 0; i < dim; i++) avg[i] /= samples.length;
      var norm = 0.0;
      for (final v in avg) norm += v * v;
      norm = math.sqrt(norm);
      if (norm == 0) throw StateError('Invalid embedding');
      final normalized = avg.map((v) => v / norm).toList();
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      await repo.saveProfile(VoiceProfile(id: id, name: n, embedding: normalized));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() { busy = false; status = 'تعذر الحفظ: ' + e.toString(); });
    }
  }

  @override Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('إضافة شخص')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم الشخص', border: OutlineInputBorder())),
        const SizedBox(height: 20),
        Text(status),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: recording || busy ? null : recordSample,
          icon: Icon(recording ? Icons.mic : Icons.graphic_eq),
          label: Text(recording ? 'جاري التسجيل...' : 'تسجيل عينة ' + (samples.length + 1).toString() + '/3'),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: samples.length / 3),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: samples.length >= 3 && name.text.trim().isNotEmpty && !busy ? save : null,
          icon: const Icon(Icons.save),
          label: const Text('حفظ البصمة الصوتية'),
        ),
      ]),
    ),
  );
}
