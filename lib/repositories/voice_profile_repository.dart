import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class VoiceProfile {
  final String id;
  final String name;
  final List<double> embedding;
  VoiceProfile({required this.id, required this.name, required this.embedding});
}

class VoiceProfileRepository {
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'voiceid.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, _) async {
      await db.execute('CREATE TABLE people(id TEXT PRIMARY KEY, name TEXT NOT NULL)');
      await db.execute('CREATE TABLE voice_profiles(person_id TEXT PRIMARY KEY, embedding BLOB NOT NULL, FOREIGN KEY(person_id) REFERENCES people(id) ON DELETE CASCADE)');
    });
    return _db!;
  }

  Future<void> saveProfile(VoiceProfile profile) async {
    final database = await db;
    final bytes = Float32List.fromList(profile.embedding).buffer.asUint8List();
    await database.transaction((tx) async {
      await tx.insert('people', {'id': profile.id, 'name': profile.name}, conflictAlgorithm: ConflictAlgorithm.replace);
      await tx.insert('voice_profiles', {'person_id': profile.id, 'embedding': bytes}, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<List<VoiceProfile>> all() async {
    final database = await db;
    final rows = await database.rawQuery('SELECT p.id,p.name,v.embedding FROM people p JOIN voice_profiles v ON v.person_id=p.id');
    return rows.map((r) {
      final bytes = r['embedding'] as Uint8List;
      final floats = Float32List.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes ~/ 4);
      return VoiceProfile(id: r['id'] as String, name: r['name'] as String, embedding: floats.toList());
    }).toList();
  }
}
