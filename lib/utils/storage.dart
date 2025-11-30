import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/auth/me.dart';


class Storage {
  static const _dbName = "age_of_gold.db";

  static final Storage _instance = Storage._internal();

  Database? based;

  factory Storage() {
    return _instance;
  }

  Storage._internal();

  Future<Database> get database async {
    if (based != null) return based!;
    based = await _initDatabase();
    return based!;
  }

  // Creates and opens the database.
  _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version,) async {
    await createTableMe(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion,) async {
    if (oldVersion == 1 && newVersion >= 2) {
    }
  }

  createTableMe(Database db) async {
    // Save all the broup information in the database
    // The messages will be a list with message ids
    await db.execute('''
      CREATE TABLE Me (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        origin INTEGER,
        avatarDefault INTEGER,
        avatarPath TEXT,
        UNIQUE(id) ON CONFLICT REPLACE
      );
    ''');
  }

  Future<void> saveMe(Me me) async {
    try {
      final db = await database;
      await db.insert(
        'Me',
        me.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // logger.e('Failed to save Me: $e');
      rethrow;
    }
  }

  Future<Me?> getMe() async {
    try {
      final db = await database;
      final maps = await db.query('Me', limit: 1);
      if (maps.isEmpty) return null;
      return Me.fromMap(maps.first);
    } catch (e) {
      // logger.e('Failed to get Me: $e');
      return null;
    }
  }

  // Clear Me from the database
  Future<void> clearMe() async {
    try {
      // TODO: Also delete any possible avatar?
      final db = await database;
      await db.delete('Me');
    } catch (e) {
      // logger.e('Failed to clear Me: $e');
      rethrow;
    }
  }


  clearDatabase() async {
    Database database = await this.database;
    await database.execute("DROP TABLE IF EXISTS Me");
    await createTableMe(database);
  }
}
