# 🏗️ Kiến Trúc Offline-First cho StudyBuddy

## 📋 Tổng Quan

StudyBuddy sử dụng kiến trúc **offline-first** kết hợp SQLite (local) và Firestore (cloud) để đảm bảo ứng dụng hoạt động mượt mà cả khi online và offline.

## 🎯 Nguyên Tắc Thiết Kế

### **1. Offline-First**
- **SQLite** là nguồn dữ liệu chính cho UI
- Tất cả CRUD operations được thực hiện trên SQLite trước
- Firestore chỉ dùng để đồng bộ và backup

### **2. Sync Queue**
- Mọi thay đổi được thêm vào hàng đợi `pending_sync`
- Sync tự động khi có kết nối mạng
- Retry mechanism với exponential backoff

### **3. Conflict Resolution**
- Sử dụng `updated_at` timestamp để so sánh
- Ưu tiên dữ liệu mới hơn
- Merge strategy cho các trường hợp đặc biệt

## 🔄 Luồng Xử Lý CRUD

### **CREATE Flow**
```
User Action → SQLite Insert → Add to Sync Queue → UI Update
                    ↓
              [When Online] → Firestore Create → Remove from Queue
```

### **UPDATE Flow**
```
User Action → SQLite Update → Add to Sync Queue → UI Update
                    ↓
              [When Online] → Firestore Update → Remove from Queue
```

### **DELETE Flow**
```
User Action → SQLite Soft Delete → Add to Sync Queue → UI Update
                    ↓
              [When Online] → Firestore Delete → Remove from Queue
```

### **READ Flow**
```
UI Request → SQLite Query → Return Data
                    ↓
              [Background] → Firestore Sync → Update SQLite
```

## 🗄️ Cấu Trúc Database

### **SQLite Schema**

```sql
-- Users Table
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
);

-- Tasks Table
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
);

-- Study Plans Table
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
);

-- Study Sessions Table
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
);

-- Pending Sync Queue
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
);
```

## 🔧 Sync Service Architecture

### **Core Components**

1. **SyncService**: Quản lý đồng bộ dữ liệu
2. **ConnectivityService**: Kiểm tra kết nối mạng
3. **TaskRepository**: CRUD operations với offline-first
4. **TaskProvider**: State management cho UI

### **Sync Process**

```dart
class SyncService {
  // 1. Lắng nghe thay đổi kết nối
  void _initializeSync() {
    _connectivitySubscription = _connectivityService.connectivityStream.listen((result) {
      if (result != ConnectivityResult.none) {
        _startPeriodicSync();
      } else {
        _stopPeriodicSync();
      }
    });
  }

  // 2. Thêm vào hàng đợi sync
  Future<void> addToSyncQueue({
    required String tableName,
    required String recordId,
    required String action,
    required Map<String, dynamic> data,
  }) async {
    await db.insert('pending_sync', {
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      'data': jsonEncode(data),
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'retry_count': 0,
      'max_retries': 3,
      'is_syncing': 0,
    });
  }

  // 3. Đồng bộ dữ liệu đang chờ
  Future<void> _syncPendingData() async {
    final pendingData = await db.query(
      'pending_sync',
      where: 'is_syncing = ? AND retry_count < max_retries',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );

    for (final record in pendingData) {
      await _syncSingleRecord(record);
    }
  }
}
```

## 📊 Conflict Resolution Strategy

### **Timestamp-based Resolution**

```dart
Future<void> _updateSQLiteIfNewer(
  String tableName,
  String recordId,
  Map<String, dynamic> firestoreData,
) async {
  final currentRecord = await db.query(
    tableName,
    where: 'id = ?',
    whereArgs: [recordId],
  );

  if (currentRecord.isNotEmpty) {
    final currentUpdatedAt = currentRecord.first['updated_at'] as int;
    final firestoreUpdatedAt = (data['updated_at'] as Timestamp).millisecondsSinceEpoch;
    
    // Chỉ cập nhật nếu Firestore mới hơn
    if (firestoreUpdatedAt > currentUpdatedAt) {
      await _updateSQLiteRecord(tableName, recordId, firestoreData);
    }
  } else {
    // Thêm mới nếu chưa tồn tại
    await _insertSQLiteRecord(tableName, firestoreData);
  }
}
```

## 🚀 Performance Optimizations

### **1. Indexes**
```sql
CREATE INDEX idx_users_uid ON users(uid);
CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_pending_sync_table ON pending_sync(table_name);
CREATE INDEX idx_pending_sync_action ON pending_sync(action);
CREATE INDEX idx_pending_sync_created_at ON pending_sync(created_at);
```

### **2. Batch Operations**
- Sync nhiều records cùng lúc
- Sử dụng transactions cho SQLite
- Debounce sync requests

### **3. Memory Management**
- Pagination cho large datasets
- Lazy loading cho UI
- Cleanup old sync records

## 🔄 Real-time Updates

### **Firestore Listeners**
```dart
void _listenToFirestoreChanges(String userId) {
  _firestore
      .collection('tasks')
      .where('user_id', isEqualTo: userId)
      .snapshots()
      .listen((snapshot) {
    _handleFirestoreChanges('tasks', snapshot);
  });
}
```

### **UI State Management**
```dart
class TaskNotifier extends StateNotifier<TaskState> {
  Future<void> createTask(TaskModel task) async {
    // 1. Lưu vào SQLite
    final createdTask = await _taskRepository.createTask(task);
    
    // 2. Cập nhật UI ngay lập tức
    final updatedTasks = [createdTask, ...state.tasks];
    state = state.copyWith(tasks: updatedTasks);
    
    // 3. Sync sẽ được thực hiện tự động
  }
}
```

## 🛡️ Error Handling

### **1. Network Errors**
- Retry với exponential backoff
- Queue persistence
- User notification

### **2. Data Conflicts**
- Timestamp comparison
- Manual conflict resolution UI
- Data validation

### **3. Sync Failures**
- Partial sync support
- Error logging
- Recovery mechanisms

## 📱 User Experience

### **1. Offline Indicators**
- Network status badge
- Sync progress indicator
- Offline mode notification

### **2. Data Consistency**
- Immediate local updates
- Background sync
- Conflict resolution UI

### **3. Performance**
- Fast local queries
- Optimistic UI updates
- Efficient sync cycles

## 🔧 Configuration

### **Sync Settings**
```dart
class SyncConfig {
  static const Duration syncInterval = Duration(minutes: 5);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(minutes: 1);
  static const int batchSize = 50;
}
```

### **Database Settings**
```dart
class DatabaseConfig {
  static const String databaseName = 'studybuddy.db';
  static const int databaseVersion = 1;
  static const bool enableWAL = true;
}
```

## 📈 Monitoring & Analytics

### **1. Sync Metrics**
- Sync success rate
- Average sync time
- Queue size monitoring

### **2. Performance Metrics**
- Query response time
- Memory usage
- Battery impact

### **3. Error Tracking**
- Network error frequency
- Data conflict rate
- User impact analysis

---

**Được tạo với ❤️ bởi Đội Ngũ StudyBuddy** 