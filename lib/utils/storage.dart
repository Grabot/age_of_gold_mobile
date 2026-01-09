import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/auth/me.dart';
import '../models/friend.dart';
import '../models/auth/user.dart';

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
    await createTableFriend(db);
    await createTableUser(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1 && newVersion >= 2) {
      await createTableFriend(db);
      await createTableUser(db);
    }
  }

  createTableMe(Database db) async {
    await db.execute('''
      CREATE TABLE Me (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        avatarVersion INTEGER,
        profileVersion INTEGER,
        origin INTEGER,
        avatarDefault INTEGER,
        avatarPath TEXT,
        UNIQUE(id) ON CONFLICT REPLACE
      );
    ''');
  }

  createTableFriend(Database db) async {
    await db.execute('''
      CREATE TABLE Friend (
        friendId INTEGER PRIMARY KEY,
        accepted INTEGER,
        friendVersion INTEGER,
        UNIQUE(friendId) ON CONFLICT REPLACE
      );
    ''');
  }

  createTableUser(Database db) async {
    await db.execute('''
      CREATE TABLE User (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        avatarPath TEXT,
        avatarVersion INTEGER,
        profileVersion INTEGER,
        shouldUpdateAvatar INTEGER DEFAULT 0,
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
      if (clearingMe.avatarPath != null) {
        await File(clearingMe.avatarPath!).delete();
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
    await database.execute("DROP TABLE IF EXISTS Friend");
    await database.execute("DROP TABLE IF EXISTS User");
    await createTableMe(database);
    await createTableFriend(database);
    await createTableUser(database);
  }

  Future<void> saveFriend(Friend friend) async {
    try {
      final db = await database;
      await db.insert(
        'Friend',
        {
          'friendId': friend.friendId,
          'accepted': friend.accepted != null ? (friend.accepted! ? 1 : 0) : null,
          'friendVersion': friend.friendVersion,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Friend>> getFriends() async {
    try {
      final db = await database;
      final maps = await db.query('Friend');
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
        'Friend',
        {
          'accepted':
              friend.accepted != null ? (friend.accepted! ? 1 : 0) : null,
          'friendVersion': friend.friendVersion,
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
      await db.delete('Friend', where: 'friendId = ?', whereArgs: [friendId]);
    } catch (e) {
      rethrow;
    }
  }

  // User methods
  Future<void> saveUser(User user) async {
    try {
      final db = await database;
      await db.insert(
        'User',
        {
          'id': user.id,
          'username': user.username,
          'avatarPath': user.avatarPath,
          'avatarVersion': user.avatarVersion ?? 1,
          'profileVersion': user.profileVersion ?? 1,
          'shouldUpdateAvatar': user.shouldUpdateAvatar ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getUser(int userId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'User',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );
       if (maps.isEmpty) return null;
       return User(
         id: maps.first['id'] as int,
         username: maps.first['username'] as String,
         avatarVersion: maps.first['avatarVersion'] as int,
         profileVersion: maps.first['profileVersion'] as int,
         avatarPath: maps.first['avatarPath'] as String?,
         shouldUpdateAvatar: maps.first['shouldUpdateAvatar'] == 1,
       );
     } catch (e) {
      return null;
    }
  }

  Future<List<User>> getUsers(List<int> userIds) async {
    try {
      final db = await database;
      final placeholders = List.filled(userIds.length, '?').join(',');
      final maps = await db.query(
        'User',
        where: 'id IN ($placeholders)',
        whereArgs: userIds,
      );
      return maps
          .map(
             (map) => User(
               id: map['id'] as int,
               username: map['username'] as String,
               avatarVersion: map['avatarVersion'] as int,
               profileVersion: map['profileVersion'] as int,
               avatarPath: map['avatarPath'] as String?,
               shouldUpdateAvatar: map['shouldUpdateAvatar'] == 1,
             ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearUsers() async {
    try {
      final db = await database;
      await db.delete('User');
    } catch (e) {
      rethrow;
    }
  }

  Future<Friend?> getFriendByFriendId(int friendId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'Friend',
        where: 'friendId = ?',
        whereArgs: [friendId],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Friend.fromMap(maps.first);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      final db = await database;
      await db.update(
        'User',
        {
          'username': user.username,
          'avatarVersion': user.avatarVersion,
          'profileVersion': user.profileVersion,
          'avatarPath': user.avatarPath,
          'shouldUpdateAvatar': user.shouldUpdateAvatar ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      rethrow;
    }
  }
}
