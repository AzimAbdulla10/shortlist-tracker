import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/placement_update.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('placement_watch.db');
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

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE placement_updates (
        gmailMessageId TEXT PRIMARY KEY,
        companyName TEXT NOT NULL,
        emailSubject TEXT NOT NULL,
        dateReceived INTEGER NOT NULL,
        snippet TEXT NOT NULL,
        status TEXT NOT NULL,
        hasExcelAttachment INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertUpdate(PlacementUpdate update) async {
    final db = await instance.database;
    return await db.insert(
      'placement_updates',
      update.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore, // Ignore duplicates
    );
  }

  Future<List<PlacementUpdate>> getAllUpdates() async {
    final db = await instance.database;
    final result = await db.query(
      'placement_updates',
      orderBy: 'dateReceived DESC',
    );
    return result.map((json) => PlacementUpdate.fromMap(json)).toList();
  }

  Future<PlacementUpdate?> getUpdateById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'placement_updates',
      where: 'gmailMessageId = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return PlacementUpdate.fromMap(result.first);
    }
    return null;
  }

  Future<bool> exists(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'placement_updates',
      columns: ['gmailMessageId'],
      where: 'gmailMessageId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<int> deleteUpdate(String id) async {
    final db = await instance.database;
    return await db.delete(
      'placement_updates',
      where: 'gmailMessageId = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearDatabase() async {
    final db = await instance.database;
    return await db.delete('placement_updates');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
