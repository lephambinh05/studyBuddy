import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import 'package:studybuddy/data/database/sqlite_database.dart';
import 'package:studybuddy/core/services/connectivity_service.dart';

enum SyncStatus { idle, syncing, error, completed }

class SyncService extends StateNotifier<SyncStatus> {
  final FirebaseFirestore _firestore;
  final ConnectivityService _connectivityService;
  Timer? _syncTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  // In-memory storage for web platform
  static final List<Map<String, dynamic>> _webPendingSync = [];

  SyncService(this._firestore, this._connectivityService) : super(SyncStatus.idle) {
    _initializeSync();
  }

  void _initializeSync() {
    // Lắng nghe thay đổi kết nối mạng
    _connectivitySubscription = _connectivityService.connectivityStream.listen((result) {
      if (result != ConnectivityResult.none) {
        // Có kết nối mạng, bắt đầu sync
        _startPeriodicSync();
      } else {
        // Mất kết nối, dừng sync
        _stopPeriodicSync();
      }
    });

    // Bắt đầu sync ngay lập tức nếu có kết nối
    _connectivityService.isConnected.then((connected) {
      if (connected) {
        _startPeriodicSync();
      }
    });
  }

  void _startPeriodicSync() {
    _stopPeriodicSync(); // Dừng timer cũ nếu có
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _syncPendingData();
    });
    // Sync ngay lập tức
    _syncPendingData();
  }

  void _stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Thêm dữ liệu vào hàng đợi sync
  Future<void> addToSyncQueue({
    required String tableName,
    required String recordId,
    required String action,
    required Map<String, dynamic> data,
  }) async {
    if (kIsWeb) {
      // Sử dụng in-memory storage cho web
      _webPendingSync.add({
        'id': DateTime.now().millisecondsSinceEpoch, // Unique ID for web
        'table_name': tableName,
        'record_id': recordId,
        'action': action,
        'data': data,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'retry_count': 0,
        'max_retries': 3,
        'is_syncing': 0,
      });
      print('Added to web sync queue: $tableName/$recordId/$action');
    } else {
      // Sử dụng SQLite cho mobile
      try {
        final db = await SQLiteDatabase.database;
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
        print('Added to SQLite sync queue: $tableName/$recordId/$action');
      } catch (e) {
        print('SQLite error, using web storage: $e');
        // Fallback to web storage
        _webPendingSync.add({
          'table_name': tableName,
          'record_id': recordId,
          'action': action,
          'data': data,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'retry_count': 0,
          'max_retries': 3,
          'is_syncing': 0,
        });
      }
    }
  }

  /// Queue data for sync (simplified interface)
  Future<void> queueForSync(String collectionName, String recordId, Map<String, dynamic> data) async {
    await addToSyncQueue(
      tableName: collectionName,
      recordId: recordId,
      action: 'create', // Default to create, can be overridden
      data: data,
    );
    
    // Force sync ngay lập tức
    await _syncPendingData();
  }

  /// Force sync ngay lập tức
  Future<void> forceSync() async {
    print('🔄 Force syncing pending data...');
    await _syncPendingData();
  }

  /// Đồng bộ dữ liệu đang chờ
  Future<void> _syncPendingData() async {
    if (state == SyncStatus.syncing) return; // Tránh sync đồng thời
    
    final isConnected = await _connectivityService.isConnected;
    if (!isConnected) {
      print('❌ SyncService: No internet connection');
      return;
    }

    print('🔄 SyncService: Starting sync process...');
    state = SyncStatus.syncing;
    
    try {
      List<Map<String, dynamic>> pendingData;
      
      if (kIsWeb) {
        // Sử dụng in-memory data cho web
        pendingData = _webPendingSync
            .where((record) => record['is_syncing'] == 0 && record['retry_count'] < record['max_retries'])
            .toList();
        print('📊 SyncService: Found ${pendingData.length} pending records in web storage');
      } else {
        // Sử dụng SQLite cho mobile
        try {
          final db = await SQLiteDatabase.database;
          pendingData = await db.query(
            'pending_sync',
            where: 'is_syncing = ? AND retry_count < max_retries',
            whereArgs: [0],
            orderBy: 'created_at ASC',
          );
          print('📊 SyncService: Found ${pendingData.length} pending records in SQLite');
        } catch (e) {
          print('❌ SQLite error, using web storage: $e');
          pendingData = _webPendingSync
              .where((record) => record['is_syncing'] == 0 && record['retry_count'] < record['max_retries'])
              .toList();
        }
      }

      if (pendingData.isEmpty) {
        print('ℹ️ SyncService: No pending data to sync');
        state = SyncStatus.completed;
        return;
      }

      print('🔄 SyncService: Syncing ${pendingData.length} pending records...');

      for (final record in pendingData) {
        await _syncSingleRecord(record);
      }

      state = SyncStatus.completed;
      print('✅ SyncService: Sync completed successfully');
      
    } catch (e) {
      print('❌ SyncService: Sync error: $e');
      state = SyncStatus.error;
    }
  }

  /// Đồng bộ một record đơn lẻ
  Future<void> _syncSingleRecord(Map<String, dynamic> record) async {
    final syncId = record['id'];
    final tableName = record['table_name'] as String;
    final recordId = record['record_id'] as String;
    final action = record['action'] as String;
    final data = kIsWeb ? record['data'] as Map<String, dynamic> : jsonDecode(record['data'] as String) as Map<String, dynamic>;

    print('🔄 SyncService: Syncing record $tableName/$recordId/$action');

    try {
      // Đánh dấu đang sync
      if (kIsWeb) {
        final index = _webPendingSync.indexWhere((r) => r['id'] == syncId);
        if (index != -1) {
          _webPendingSync[index]['is_syncing'] = 1;
        }
      } else {
        try {
          final db = await SQLiteDatabase.database;
          await db.update(
            'pending_sync',
            {'is_syncing': 1},
            where: 'id = ?',
            whereArgs: [syncId],
          );
        } catch (e) {
          print('❌ SQLite error during sync: $e');
        }
      }

      // Thực hiện sync với Firestore
      print('📡 SyncService: Performing Firestore action...');
      await _performFirestoreAction(tableName, recordId, action, data);

      // Xóa khỏi hàng đợi sau khi sync thành công
      if (kIsWeb) {
        _webPendingSync.removeWhere((r) => r['id'] == syncId);
      } else {
        try {
          final db = await SQLiteDatabase.database;
          await db.delete(
            'pending_sync',
            where: 'id = ?',
            whereArgs: [syncId],
          );
        } catch (e) {
          print('❌ SQLite error during cleanup: $e');
        }
      }

      print('✅ SyncService: Successfully synced $tableName/$recordId/$action');

    } catch (e) {
      print('❌ SyncService: Sync failed for $tableName/$recordId/$action: $e');
      
      // Tăng số lần retry
      if (kIsWeb) {
        final index = _webPendingSync.indexWhere((r) => r['id'] == syncId);
        if (index != -1) {
          _webPendingSync[index]['is_syncing'] = 0;
          _webPendingSync[index]['retry_count'] = (_webPendingSync[index]['retry_count'] as int) + 1;
        }
      } else {
        try {
          final db = await SQLiteDatabase.database;
          await db.update(
            'pending_sync',
            {
              'is_syncing': 0,
              'retry_count': (record['retry_count'] as int) + 1,
            },
            where: 'id = ?',
            whereArgs: [syncId],
          );
        } catch (e) {
          print('❌ SQLite error during retry: $e');
        }
      }
    }
  }

  /// Thực hiện action trên Firestore
  Future<void> _performFirestoreAction(
    String tableName,
    String recordId,
    String action,
    Map<String, dynamic> data,
  ) async {
    print('🔥 Firestore: Performing $action on $tableName/$recordId');
    print('📊 Firestore: Data: $data');
    
    final collection = _firestore.collection(tableName);
    final document = collection.doc(recordId);

    try {
      switch (action) {
        case 'create':
          print('🔥 Firestore: Creating document...');
          await document.set(data);
          print('✅ Firestore: Document created successfully');
          break;
        case 'update':
          print('🔥 Firestore: Updating document...');
          await document.update(data);
          print('✅ Firestore: Document updated successfully');
          break;
        case 'delete':
          print('🔥 Firestore: Deleting document...');
          await document.delete();
          print('✅ Firestore: Document deleted successfully');
          break;
        default:
          throw Exception('Unknown action: $action');
      }
    } catch (e) {
      print('❌ Firestore: Error performing $action: $e');
      rethrow;
    }
  }

  /// Lắng nghe thay đổi từ Firestore và cập nhật SQLite
  void _listenToFirestoreChanges(String userId) {
    // Lắng nghe thay đổi tasks
    _firestore
        .collection('tasks')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _handleFirestoreChanges('tasks', snapshot);
    });

    // Lắng nghe thay đổi study_plans
    _firestore
        .collection('study_plans')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _handleFirestoreChanges('study_plans', snapshot);
    });

    // Lắng nghe thay đổi study_targets
    _firestore
        .collection('study_targets')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _handleFirestoreChanges('study_targets', snapshot);
    });
  }

  /// Xử lý thay đổi từ Firestore
  Future<void> _handleFirestoreChanges(
    String tableName,
    QuerySnapshot snapshot,
  ) async {
    final db = await SQLiteDatabase.database;
    
    for (final change in snapshot.docChanges) {
      final doc = change.doc;
      final data = doc.data() as Map<String, dynamic>;
      final recordId = doc.id;

      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          // Cập nhật SQLite nếu timestamp mới hơn
          await _updateSQLiteIfNewer(tableName, recordId, data);
          break;
        case DocumentChangeType.removed:
          // Xóa khỏi SQLite
          await db.update(
            tableName,
            {'is_deleted': 1},
            where: 'id = ?',
            whereArgs: [recordId],
          );
          break;
      }
    }
  }

  /// Cập nhật SQLite chỉ khi dữ liệu Firestore mới hơn
  Future<void> _updateSQLiteIfNewer(
    String tableName,
    String recordId,
    Map<String, dynamic> firestoreData,
  ) async {
    final db = await SQLiteDatabase.database;
    
    // Kiểm tra timestamp hiện tại trong SQLite
    final currentRecord = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [recordId],
    );

    if (currentRecord.isNotEmpty) {
      final currentUpdatedAt = currentRecord.first['updated_at'] as int;
      final firestoreUpdatedAt = firestoreData['updated_at'] as int;

      // Chỉ cập nhật nếu Firestore mới hơn
      if (firestoreUpdatedAt > currentUpdatedAt) {
        await _updateSQLiteRecord(tableName, recordId, firestoreData);
      }
    } else {
      // Record chưa tồn tại, thêm mới
      await _insertSQLiteRecord(tableName, firestoreData);
    }
  }

  /// Cập nhật record trong SQLite
  Future<void> _updateSQLiteRecord(
    String tableName,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    final db = await SQLiteDatabase.database;
    
    // Chuyển đổi dữ liệu cho SQLite
    final sqliteData = _convertToSQLiteFormat(data);
    
    await db.update(
      tableName,
      sqliteData,
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  /// Thêm record mới vào SQLite
  Future<void> _insertSQLiteRecord(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    final db = await SQLiteDatabase.database;
    
    // Chuyển đổi dữ liệu cho SQLite
    final sqliteData = _convertToSQLiteFormat(data);
    
    await db.insert(tableName, sqliteData);
  }

  /// Chuyển đổi dữ liệu từ Firestore format sang SQLite format
  Map<String, dynamic> _convertToSQLiteFormat(Map<String, dynamic> firestoreData) {
    final sqliteData = Map<String, dynamic>.from(firestoreData);
    
    // Chuyển đổi Timestamp thành milliseconds
    if (sqliteData['created_at'] is Timestamp) {
      sqliteData['created_at'] = (sqliteData['created_at'] as Timestamp).millisecondsSinceEpoch;
    }
    if (sqliteData['updated_at'] is Timestamp) {
      sqliteData['updated_at'] = (sqliteData['updated_at'] as Timestamp).millisecondsSinceEpoch;
    }
    if (sqliteData['last_login'] is Timestamp) {
      sqliteData['last_login'] = (sqliteData['last_login'] as Timestamp).millisecondsSinceEpoch;
    }
    if (sqliteData['due_date'] is Timestamp) {
      sqliteData['due_date'] = (sqliteData['due_date'] as Timestamp).millisecondsSinceEpoch;
    }
    if (sqliteData['start_date'] is Timestamp) {
      sqliteData['start_date'] = (sqliteData['start_date'] as Timestamp).millisecondsSinceEpoch;
    }
    if (sqliteData['end_date'] is Timestamp) {
      sqliteData['end_date'] = (sqliteData['end_date'] as Timestamp).millisecondsSinceEpoch;
    }
    if (sqliteData['start_time'] is Timestamp) {
      sqliteData['start_time'] = (sqliteData['start_time'] as Timestamp).millisecondsSinceEpoch;
    }
    if (sqliteData['end_time'] is Timestamp) {
      sqliteData['end_time'] = (sqliteData['end_time'] as Timestamp).millisecondsSinceEpoch;
    }

    return sqliteData;
  }

  /// Bắt đầu lắng nghe thay đổi từ Firestore cho user cụ thể
  void startListeningToUser(String userId) {
    _listenToFirestoreChanges(userId);
  }

  /// Dừng lắng nghe
  void stopListening() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

// Riverpod providers
final syncServiceProvider = StateNotifierProvider<SyncService, SyncStatus>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  return SyncService(firestore, connectivityService);
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
