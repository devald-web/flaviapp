import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flaviapp/models/migraine_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flaviapp.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE migraine_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        hadMigraine INTEGER NOT NULL DEFAULT 1,
        medication TEXT,
        trigger TEXT,
        intensity TEXT NOT NULL,
        notes TEXT
      )
    ''');
    await db.execute('CREATE INDEX idx_date ON migraine_entries (date)');
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<int> insertEntry(MigraineEntry entry) async {
    final db = await instance.database;
    final formattedDate = _formatDate(entry.date);

    // Verificar si ya existe una entrada para esta fecha
    final existingEntry = await getEntryByDate(entry.date);
    if (existingEntry != null) {
      // Si existe, actualizar en lugar de insertar
      return await updateEntry(entry);
    }

    final Map<String, dynamic> entryMap = {
      'date': formattedDate,
      'hadMigraine': entry.hadMigraine ? 1 : 0,
      'medication': entry.medication,
      'trigger': entry.trigger,
      'intensity': entry.intensity,
      'notes': entry.notes,
    };

    return db.insert('migraine_entries', entryMap);
  }

  Future<int> updateEntry(MigraineEntry entry) async {
    final db = await instance.database;
    final formattedDate = _formatDate(entry.date);

    final Map<String, dynamic> entryMap = {
      'date': formattedDate,
      'hadMigraine': entry.hadMigraine ? 1 : 0,
      'medication': entry.medication,
      'trigger': entry.trigger,
      'intensity': entry.intensity,
      'notes': entry.notes,
    };

    return await db.update(
      'migraine_entries',
      entryMap,
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<MigraineEntry?> getEntryByDate(DateTime date) async {
    final db = await instance.database;
    final formattedDate = _formatDate(date);

    final maps = await db.query(
      'migraine_entries',
      where: 'date = ?',
      whereArgs: [formattedDate],
    );

    if (maps.isEmpty) return null;

    return MigraineEntry(
      id: maps.first['id'] as int,
      date: DateTime.parse(maps.first['date'] as String),
      hadMigraine: (maps.first['hadMigraine'] as int) == 1,
      medication: maps.first['medication'] as String?,
      trigger: maps.first['trigger'] as String?,
      intensity: maps.first['intensity'] as String?,
      notes: maps.first['notes'] as String?,
    );
  }

  Future<List<String>> getDatesWithEntries() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'migraine_entries',
      columns: ['date'],
      orderBy: 'date DESC',
    );
    return maps.map((map) => map['date'] as String).toList();
  }

  Future<int> deleteEntry(int id) async {
    final db = await instance.database;
    return await db.delete(
      'migraine_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<MigraineEntry>> getAllEntries() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'migraine_entries',
      orderBy: 'date DESC',
    );

    return maps.map((map) => MigraineEntry(
      id: map['id'] as int,
      date: DateTime.parse(map['date'] as String),
      hadMigraine: (map['hadMigraine'] as int) == 1,
      medication: map['medication'] as String?,
      trigger: map['trigger'] as String?,
      intensity: map['intensity'] as String?,
      notes: map['notes'] as String?,
    )).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}