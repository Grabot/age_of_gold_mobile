import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/auth/me.dart';
import '../models/friend.dart';

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

  _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await createTableMe(db);
    await createTableFriends(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1 && newVersion >= 2) {
      await createTableFriends(db);
    }
  }

  createTableMe(Database db) async {
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

  createTableFriends(Database db) async {
    await db.execute('''
      CREATE TABLE Friends (
        id INTEGER PRIMARY KEY,
        friend_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        accepted INTEGER,
        friend_version INTEGER,
        username TEXT,
        avatar_path TEXT,
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

  Future<void> clearMe() async {
    try {
      final db = await database;
      final maps = await db.query('Me', limit: 1);
      if (maps.isEmpty) return;
      Me clearingMe = Me.fromMap(maps.first);
      if (clearingMe.user.avatarPath != null) {
        await File(clearingMe.user.avatarPath!).delete();
      }
      await db.delete('Me');
    } catch (e) {
      // logger.e('Failed to clear Me: $e');
      rethrow;
    }
  }

  clearDatabase() async {
    Database database = await this.database;
    await database.execute("DROP TABLE IF EXISTS Me");
    await database.execute("DROP TABLE IF EXISTS Friends");
    await createTableMe(database);
    await createTableFriends(database);
  }

  Future<void> saveFriend(Friend friend) async {
    try {
      final db = await database;
      await db.insert('Friends', {
        'friend_id': friend.friendId,
        'accepted': friend.accepted != null ? (friend.accepted! ? 1 : 0) : null,
        'friend_version': friend.friendVersion,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Friend>> getFriends() async {
    try {
      final db = await database;
      final maps = await db.query('Friends');
      return maps.map((map) => Friend.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearFriends() async {
    try {
      final db = await database;
      await db.delete('Friends');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFriend(Friend friend) async {
    try {
      final db = await database;
      await db.update(
        'Friends',
        {
          'accepted':
              friend.accepted != null ? (friend.accepted! ? 1 : 0) : null,
          'friend_version': friend.friendVersion,
        },
        where: 'friendId = ?',
        whereArgs: [friend.friendId],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFriend(int friendId) async {
    try {
      final db = await database;
      await db.delete('Friends', where: 'friendId = ?', whereArgs: [friendId]);
    } catch (e) {
      rethrow;
    }
  }
}
