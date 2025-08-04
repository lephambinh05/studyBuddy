import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/data/models/task.dart'; // Import model của bạn
// import 'package:uuid/uuid.dart'; // Nếu bạn muốn tạo UUID cho ID cục bộ

// Tên bảng và cột
const String tableTasks = 'tasks';
const String columnId = 'id';
const String columnTitle = 'title';
const String columnDescription = 'description';
const String columnDueDate = 'dueDate';
const String columnPriority = 'priority';
const String columnStatus = 'status';
const String columnUserId = 'userId';
const String columnStudyPlanId = 'studyPlanId';
const String columnCreatedAt = 'createdAt';
const String columnUpdatedAt = 'updatedAt';
const String columnIsSynced = 'isSynced'; // 0 for false, 1 for true

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
  static Database? _database;

  // static const _uuid = Uuid(); // Nếu dùng uuid

  LocalDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('studybuddy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1, // Tăng version khi thay đổi schema
      onCreate: _createDB,
      // onUpgrade: _onUpgradeDB, // TODO: Implement if schema changes
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTasks (
        $columnId TEXT PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnDescription TEXT,
        $columnDueDate TEXT NOT NULL, -- Lưu dưới dạng ISO8601 String
        $columnPriority TEXT NOT NULL, -- Lưu tên của enum
        $columnStatus TEXT NOT NULL, -- Lưu tên của enum
        $columnUserId TEXT NOT NULL,
        $columnStudyPlanId TEXT,
        $columnCreatedAt TEXT, -- Lưu dưới dạng ISO8601 String
        $columnUpdatedAt TEXT, -- Lưu dưới dạng ISO8601 String
        $columnIsSynced INTEGER NOT NULL DEFAULT 1 -- 0 for false, 1 for true
      )
    ''');
    // TODO: Tạo các bảng khác nếu cần (ví dụ: study_plans, user_settings)
  }

  // Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
  //   if (oldVersion < 2) {
  //     // await db.execute("ALTER TABLE $tableTasks ADD COLUMN new_column TEXT;");
  //   }
  //   // Thêm các logic migration khác nếu cần
  // }

  // --- CRUD Operations cho Tasks ---

  Future<String> insertTask(TaskModel task) async {
    final db = await instance.database;
    // Đảm bảo task có ID, nếu không có và đang tạo cục bộ, có thể tạo ở đây
    // final taskToInsert = task.id.isEmpty ? task.copyWith(id: _uuid.v4()) : task;
    final id = await db.insert(tableTasks, task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return id.toString(); // `insert` trả về row ID, nhưng ta dùng `task.id` làm PK
  }

  Future<TaskModel?> getTaskById(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableTasks,
      columns: null, // Lấy tất cả các cột
      where: '$columnId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TaskModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<TaskModel>> getAllTasks(String userId) async {
    final db = await instance.database;
    final result = await db.query(
        tableTasks,
        where: '$columnUserId = ?',
        whereArgs: [userId],
        orderBy: '$columnDueDate ASC'
    );
    return result.map((json) => TaskModel.fromMap(json)).toList();
  }

  Future<List<TaskModel>> getUnsyncedTasks(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      tableTasks,
      where: '$columnUserId = ? AND $columnIsSynced = ?',
      whereArgs: [userId, 0], // 0 for false
    );
    return result.map((json) => TaskModel.fromMap(json)).toList();
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await instance.database;
    return db.update(
      tableTasks,
      task.toMap(),
      where: '$columnId = ?',
      whereArgs: [task.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteTask(String id) async {
    final db = await instance.database;
    return await db.delete(
      tableTasks,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllTasksForUser(String userId) async {
    final db = await instance.database;
    await db.delete(
      tableTasks,
      where: '$columnUserId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> clearAllTasks() async { // Dùng cẩn thận!
    final db = await instance.database;
    await db.delete(tableTasks);
  }


  Future<void> insertOrUpdateTask(TaskModel task) async {
    final db = await instance.database;
    await db.insert(
      tableTasks,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Nếu ID đã tồn tại, sẽ cập nhật
    );
  }


  Future<void> close() async {
    final db = await instance.database;
    _database = null; // Quan trọng để có thể mở lại DB nếu cần
    await db.close();
  }
}

// Riverpod provider cho LocalDatabaseService (tùy chọn, có thể dùng instance trực tiếp)
final localDatabaseServiceProvider = Provider<LocalDatabaseService>((ref) {
  final dbService = LocalDatabaseService.instance;
  // Bạn có thể thực hiện một số thiết lập ban đầu ở đây nếu cần
  // Ví dụ: dbService.database; // Để đảm bảo DB được khởi tạo
  return dbService;
});
