import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/migraine_entry.dart';

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
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
   await db.execute('''
      CREATE TABLE migraine_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        hadMigraine INTEGER NOT NULL,
        medication TEXT,
        trigger TEXT,
        intensity TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }


  Future<int> insertEntry(MigraineEntry entry) async {
    final db = await instance.database;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final formattedDate = dateFormat.format(entry.date);
    final entryWithFormattedDate = entry.copyWith(date: DateTime.parse(formattedDate));
    print('Inserting entry: ${entryWithFormattedDate.toMap()}');
    final id = await db.insert('migraine_entries', entryWithFormattedDate.toMap());
    print('Inserted entry with id: $id');
    return id;
  }

  Future<MigraineEntry?> getEntryByDate(DateTime date) async {
    final db = await instance.database;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final formattedDate = dateFormat.format(date);
    print('Querying for date: $formattedDate');
    final result = await db.query(
      'migraine_entries',
      where: 'date LIKE ?',
      whereArgs: ['$formattedDate%'],
    );
    if (result.isNotEmpty) {
      print('Entry found: ${result.first}');
      return MigraineEntry.fromMap(result.first);
    }
    print('No entry found for date: $formattedDate');
    return null;
  }

  Future<int> updateEntry(MigraineEntry entry) async {
    final db = await instance.database;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final formattedDate = dateFormat.format(entry.date);
    final entryMap = entry.toMap();
    entryMap.remove('id');
    print('Updating entry: $entryMap');
    return await db.update(
      'migraine_entries',
      entryMap,
      where: 'date LIKE ?',
      whereArgs: ['$formattedDate%'],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await instance.database;
    return await db.delete(
      'migraine_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<MigraineEntry>> getEntries() async {
    final db = await instance.database;
    final result = await db.query('migraine_entries');
    print('OBTENIENDO RESULTADOS: $result');
    return result.map((map) => MigraineEntry.fromMap(map)).toList();
  }

  Future<List<String>> getDatesWithEntries() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT DISTINCT date FROM migraine_entries');
    return result.map((row) => row['date'] as String).toList();
  }
}