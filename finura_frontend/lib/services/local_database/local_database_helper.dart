import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FinuraLocalDbHelper {
  static final FinuraLocalDbHelper _instance = FinuraLocalDbHelper._internal();
  factory FinuraLocalDbHelper() => _instance;
  FinuraLocalDbHelper._internal();

  static Database? _database;

  static var navigatorKey = GlobalKey<NavigatorState>();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = join(dbPath, 'finura_local_database.db');

    // Ensure the directory exists
    print('Using database at: $dbFilePath');

    return await openDatabase(
      dbFilePath,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user (
        id TEXT PRIMARY KEY,
        pin_hash TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        occupation TEXT,
        sex TEXT CHECK(sex IN ('male', 'female', 'other')) NOT NULL,
        created_at TEXT NOT NULL,
        user_photo TEXT,
        data_status TEXT
      )
    ''');

    // 🚨 New table for expense tracking
    await db.execute('''
    CREATE TABLE expense_entry (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      date TEXT NOT NULL,
      day INTEGER NOT NULL,
      time TEXT NOT NULL,
      mood INTEGER NOT NULL CHECK(mood BETWEEN 0 AND 5),
      description TEXT,
      expense_amount REAL NOT NULL,
      synced INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY(user_id) REFERENCES user(id) ON DELETE CASCADE
    )
  ''');

    //table for income tracking
    await db.execute('''
      CREATE TABLE income_entry (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        day INTEGER NOT NULL,
        time TEXT NOT NULL,
        mood INTEGER NOT NULL CHECK(mood BETWEEN 0 AND 5),
        description TEXT,
        income_amount REAL NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES user(id) ON DELETE CASCADE
      )
    ''');

    // Table for saving goals
    // Updated Saving Goal table
    await db.execute('''
  CREATE TABLE saving_goal (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    monthly_income REAL NOT NULL,
    target_saving REAL NOT NULL,
    target_expense_limit REAL NOT NULL,
    frequency REAL NOT NULL,
    start_date TEXT NOT NULL,
    end_date TEXT,
    current_saved REAL DEFAULT 0,
    description TEXT,
    synced INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY(user_id) REFERENCES user(id) ON DELETE CASCADE
  )
''');

    // Table for note enrtes
    await db.execute('''
      CREATE TABLE note_entry (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES user(id) ON DELETE CASCADE
      )
    ''');

    // New Notification table
    await db.execute('''
  CREATE TABLE notification (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    predicted_expense_amount REAL NOT NULL,
    predicted_mood INTEGER NOT NULL,
    predicted_time TEXT NOT NULL,
    push_time TEXT NOT NULL,
    notif_message TEXT NOT NULL,
    notif_status INTEGER DEFAULT 0,
    harm_level TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES user(id) ON DELETE CASCADE
  )
''');

    print('Database created with expense_entry table.');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add any upgrade logic for version 2
      await db.execute('''
    CREATE TABLE expense_entry (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      date TEXT NOT NULL,
      day INTEGER NOT NULL,
      time TEXT NOT NULL,
      mood INTEGER NOT NULL CHECK(mood BETWEEN 0 AND 5),
      description TEXT,
      expense_amount REAL NOT NULL,
      synced INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY(user_id) REFERENCES user(id) ON DELETE CASCADE
    )
  ''');
    }
    if (oldVersion < 3) {
      // Add any upgrade logic for version 3
      await db.execute('''
        CREATE TABLE income_entry (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          date TEXT NOT NULL,
          day INTEGER NOT NULL,
          time TEXT NOT NULL,
          mood INTEGER NOT NULL CHECK(mood BETWEEN 0 AND 5),
          description TEXT,
          income_amount REAL NOT NULL,
          synced INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(user_id) REFERENCES user(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
      CREATE TABLE saving_goal (
       id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        target_amount REAL NOT NULL,
        frequency TEXT NOT NULL CHECK(frequency IN ('daily', 'weekly', 'monthly')),
        start_date TEXT NOT NULL,
        end_date TEXT,
        current_saved REAL NOT NULL DEFAULT 0,
        description TEXT,
        synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES user(id) ON DELETE CASCADE
      )
    ''');

      await db.execute('''
      CREATE TABLE note_entry (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES user(id) ON DELETE CASCADE
      )
    ''');
    }
    if (oldVersion < 5) {
      // Add the updated saving_goal
      await db.execute('DROP TABLE IF EXISTS saving_goal');
      await db.execute('''
    CREATE TABLE saving_goal (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      monthly_income REAL NOT NULL,
      target_saving REAL NOT NULL,
      target_expense_limit REAL NOT NULL,
      frequency REAL NOT NULL,
      start_date TEXT NOT NULL,
      end_date TEXT,
      current_saved REAL DEFAULT 0,
      description TEXT,
      synced INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY(user_id) REFERENCES user(id) ON DELETE CASCADE
    )
  ''');

      // Add notification table
      await db.execute('''
    CREATE TABLE notification (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      predicted_expense_amount REAL NOT NULL,
      predicted_mood INTEGER NOT NULL,
      predicted_time TEXT NOT NULL,
      push_time TEXT NOT NULL,
      notif_message TEXT NOT NULL,
      notif_status INTEGER DEFAULT 0,
      harm_level TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(user_id) REFERENCES user(id) ON DELETE CASCADE
    )
  ''');
    }

    print('Database upgraded from version $oldVersion to $newVersion.');
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('user');
  }

  // Optional: helper to debug tables
  Future<void> debugPrintTables() async {
    final db = await database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    print("📋 Tables in DB: $tables");
  }

  // Optional: Dev-only reset method (call this manually if needed)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = join(dbPath, 'finura_local_database.db');
    await deleteDatabase(dbFilePath);
    _database = null; // Clear cached instance
    print("Database has been reset.");
  }
}
