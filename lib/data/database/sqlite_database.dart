import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class SQLiteDatabase {
  static Database? _database;
  static const String _databaseName = 'studybuddy.db';
  static const int _databaseVersion = 1;

  // Singleton pattern
  static Future<Database> get database async {
    // SQLite không hoạt động trên web, trả về null
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web platform');
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Bảng Users
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        uid TEXT NOT NULL,
        email TEXT NOT NULL,
        display_name TEXT NOT NULL,
        photo_url TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        last_login INTEGER NOT NULL,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    // Bảng Tasks
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date INTEGER,
        priority INTEGER DEFAULT 0,
        status TEXT DEFAULT 'pending',
        category TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Bảng Study Plans
    await db.execute('''
      CREATE TABLE study_plans (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Bảng Study Sessions
    await db.execute('''
      CREATE TABLE study_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        task_id TEXT,
        study_plan_id TEXT,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        duration INTEGER,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (task_id) REFERENCES tasks (id),
        FOREIGN KEY (study_plan_id) REFERENCES study_plans (id)
      )
    ''');

    // Bảng Study Targets
    await db.execute('''
      CREATE TABLE study_targets (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        target_type TEXT NOT NULL,
        target_value REAL NOT NULL,
        current_value REAL DEFAULT 0,
        unit TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER,
        is_completed INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Bảng Pending Sync - Quan trọng nhất!
    await db.execute('''
      CREATE TABLE pending_sync (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        action TEXT NOT NULL, -- 'create', 'update', 'delete'
        data TEXT NOT NULL, -- JSON data
        created_at INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0,
        max_retries INTEGER DEFAULT 3,
        is_syncing INTEGER DEFAULT 0
      )
    ''');

    // Indexes để tối ưu performance
    await db.execute('CREATE INDEX idx_users_uid ON users(uid)');
    await db.execute('CREATE INDEX idx_tasks_user_id ON tasks(user_id)');
    await db.execute('CREATE INDEX idx_tasks_status ON tasks(status)');
    await db.execute('CREATE INDEX idx_study_targets_user_id ON study_targets(user_id)');
    await db.execute('CREATE INDEX idx_study_targets_type ON study_targets(target_type)');
    await db.execute('CREATE INDEX idx_study_targets_completed ON study_targets(is_completed)');
    await db.execute('CREATE INDEX idx_pending_sync_table ON pending_sync(table_name)');
    await db.execute('CREATE INDEX idx_pending_sync_action ON pending_sync(action)');
    await db.execute('CREATE INDEX idx_pending_sync_created_at ON pending_sync(created_at)');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Xử lý migration khi cập nhật database
    if (oldVersion < 2) {
      // Thêm cột mới nếu cần
    }
  }

  // Helper methods
  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
} 