import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_progress.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('echolearn.db');
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
      CREATE TABLE user_progress (
        skillId TEXT,
        difficulty INTEGER,
        score INTEGER,
        isCompleted INTEGER,
        PRIMARY KEY (skillId, difficulty)
      )
    ''');
  }

  Future<int> saveProgress(UserProgress progress) async {
    final db = await instance.database;
    return await db.insert(
      'user_progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserProgress>> getProgressForSkill(String skillId) async {
    final db = await instance.database;
    final result = await db.query(
      'user_progress',
      where: 'skillId = ?',
      whereArgs: [skillId],
    );

    return result.map((json) => UserProgress.fromMap(json)).toList();
  }

  Future<UserProgress?> getSpecificProgress(String skillId, int difficulty) async {
    final db = await instance.database;
    final result = await db.query(
      'user_progress',
      where: 'skillId = ? AND difficulty = ?',
      whereArgs: [skillId, difficulty],
    );

    if (result.isNotEmpty) {
      return UserProgress.fromMap(result.first);
    } else {
      return null;
    }
  }
}
