import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('VoiceID')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('نظام التعرف على المتحدث',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('التعرف محليًا باستخدام Speaker Embeddings'),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mic),
              label: const Padding(
                padding: EdgeInsets.all(14),
                child: Text('التعرف المباشر'),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add),
              label: const Padding(
                padding: EdgeInsets.all(14),
                child: Text('إضافة شخص'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
