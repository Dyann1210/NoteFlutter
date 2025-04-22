import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_01/NoteMS/model/note.dart';

class NoteDatabaseHelper {
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database;

  NoteDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'notes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            priority INTEGER,
            createdAt TEXT,
            modifiedAt TEXT,
            tags TEXT,
            color TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query('notes');
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? Note.fromMap(maps.first) : null;
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Note>> getNotesByPriority(int priority) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'priority = ?',
      whereArgs: [priority],
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}