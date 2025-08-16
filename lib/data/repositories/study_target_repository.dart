import 'package:studybuddy/data/models/study_target.dart';
import 'package:studybuddy/data/database/sqlite_database.dart';
import 'package:studybuddy/core/services/sync_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:studybuddy/data/sources/local/study_target_local_storage.dart';

class StudyTargetRepository {
  static const String _tableName = 'study_targets';
  static const String _collectionName = 'study_targets';
  
  final SyncService _syncService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = Uuid();
  
  // In-memory storage for web platform
  static final List<StudyTarget> _webTargets = [];

  String? get _currentUserId => _auth.currentUser?.uid;

  StudyTargetRepository(this._syncService);

  // Load data from Firebase
  Future<void> loadFromFirebase(String userId) async {
    print('🔄 StudyTargetRepository: Loading from Firebase for user $userId');
    
    try {
      print('📡 StudyTargetRepository: Querying Firebase collection: $_collectionName');
      
      // Thử query đơn giản trước
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('user_id', isEqualTo: userId)
          .get();

      print('📊 StudyTargetRepository: Firebase returned ${snapshot.docs.length} study targets');
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        print('📋 StudyTargetRepository: Processing target: ${data['title']} (ID: ${doc.id})');
        print('📊 StudyTargetRepository: Full data: $data');
        
        try {
          final target = StudyTarget.fromFirebaseJson(data);
          print('✅ StudyTargetRepository: Successfully parsed target: ${target.title}');
          
          if (kIsWeb) {
            // Update in-memory storage
            print('🌐 StudyTargetRepository: Updating in-memory storage');
            final index = _webTargets.indexWhere((t) => t.id == target.id);
            if (index != -1) {
              _webTargets[index] = target;
              print('🔄 StudyTargetRepository: Updated existing target in memory');
            } else {
              _webTargets.add(target);
              print('➕ StudyTargetRepository: Added new target to memory');
            }
          } else {
            // Update SQLite
            print('📱 StudyTargetRepository: Updating SQLite storage');
            try {
              final db = await SQLiteDatabase.database;
              final existing = await db.query(_tableName, where: 'id = ?', whereArgs: [target.id]);
              if (existing.isNotEmpty) {
                await db.update(_tableName, _toMap(target), where: 'id = ?', whereArgs: [target.id]);
                print('🔄 StudyTargetRepository: Updated existing target in SQLite');
              } else {
                await db.insert(_tableName, _toMap(target));
                print('➕ StudyTargetRepository: Added new target to SQLite');
              }
            } catch (e) {
              print('❌ SQLite error: $e');
              // Fallback to in-memory storage
              print('🔄 StudyTargetRepository: Falling back to in-memory storage');
              final index = _webTargets.indexWhere((t) => t.id == target.id);
              if (index != -1) {
                _webTargets[index] = target;
              } else {
                _webTargets.add(target);
              }
            }
          }
        } catch (e) {
          print('❌ StudyTargetRepository: Error parsing target: $e');
        }
      }
      
      print('✅ StudyTargetRepository: Successfully loaded ${snapshot.docs.length} targets from Firebase');
    } catch (e) {
      print('❌ StudyTargetRepository: Error loading from Firebase: $e');
    }
  }

  // Create study target
  Future<StudyTarget> createStudyTarget(StudyTarget target) async {
    print('🔄 StudyTargetRepository: Starting createStudyTarget...');
    print('📊 StudyTargetRepository: Target Title: ${target.title}');
    
    try {
      final now = DateTime.now();
      
      final newTarget = target.copyWith(
        id: target.id.isEmpty ? _uuid.v4() : target.id,
        createdAt: now,
        updatedAt: now,
      );

      print('🆔 StudyTargetRepository: Generated ID: ${newTarget.id}');
      
      // Thêm vào Firebase
      await _firestore.collection(_collectionName).doc(newTarget.id).set(_toMap(newTarget));
      
      // Lưu vào local storage để backup
      await StudyTargetLocalStorage.addStudyTarget(newTarget);
      
      print('✅ StudyTargetRepository: Added to Firebase and local storage');
      return newTarget;
    } catch (e) {
      print('❌ StudyTargetRepository: Error adding to Firebase: $e');
      
      // Nếu Firebase lỗi, vẫn lưu vào local storage
      print('🔄 StudyTargetRepository: Saving to local storage as backup...');
      final now = DateTime.now();
      final tempTarget = target.copyWith(
        id: target.id.isEmpty ? _uuid.v4() : target.id,
        createdAt: now,
        updatedAt: now,
      );
      await StudyTargetLocalStorage.addStudyTarget(tempTarget);
      
      print('📱 StudyTargetRepository: Saved to local storage with ID: ${tempTarget.id}');
      return tempTarget;
    }
  }

  // Get all study targets for user
  Future<List<StudyTarget>> getStudyTargets(String userId) async {
    print('🔄 StudyTargetRepository: Getting study targets for user: $userId');
    
    try {
      // Thử lấy từ Firebase trước
      print('📡 StudyTargetRepository: Querying Firebase collection: $_collectionName');
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('user_id', isEqualTo: userId)
          .where('is_deleted', isEqualTo: false)
          .orderBy('created_at', descending: true)
          .get();

      final targets = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return StudyTarget.fromFirebaseJson(data);
          })
          .toList();

      print('✅ StudyTargetRepository: Firebase returned ${targets.length} targets');
      
      // Lưu vào local storage để backup
      await StudyTargetLocalStorage.saveStudyTargets(targets);
      
      return targets;
    } catch (e) {
      print('❌ StudyTargetRepository: Error loading from Firebase: $e');
      print('🔄 StudyTargetRepository: Trying local storage...');
      
      // Nếu Firebase lỗi, lấy từ local storage
      final localTargets = await StudyTargetLocalStorage.getStudyTargets();
      print('📱 StudyTargetRepository: Local storage has ${localTargets.length} targets');
      
      return localTargets;
    }
  }

  // Get study target by ID
  Future<StudyTarget?> getStudyTarget(String id) async {
    if (kIsWeb) {
      // Use in-memory storage for web
      try {
        return _webTargets.firstWhere((target) => target.id == id && !target.isDeleted);
      } catch (e) {
        return null;
      }
    } else {
      // Use SQLite for mobile
      try {
        final db = await SQLiteDatabase.database;
        final results = await db.query(
          _tableName,
          where: 'id = ? AND is_deleted = 0',
          whereArgs: [id],
          limit: 1,
        );
        
        if (results.isEmpty) return null;
        return _fromMap(results.first);
      } catch (e) {
        print('SQLite error: $e');
        // Fallback to in-memory storage
        try {
          return _webTargets.firstWhere((target) => target.id == id && !target.isDeleted);
        } catch (e) {
          return null;
        }
      }
    }
  }

  // Update study target
  Future<StudyTarget> updateStudyTarget(StudyTarget target) async {
    final now = DateTime.now();
    final updatedTarget = target.copyWith(updatedAt: now);

    if (kIsWeb) {
      // Use in-memory storage for web
      final index = _webTargets.indexWhere((t) => t.id == target.id);
      if (index != -1) {
        _webTargets[index] = updatedTarget;
      }
    } else {
      // Use SQLite for mobile
      try {
        final db = await SQLiteDatabase.database;
        await db.update(
          _tableName,
          _toMap(updatedTarget),
          where: 'id = ?',
          whereArgs: [target.id],
        );
      } catch (e) {
        print('SQLite error: $e');
        // Fallback to in-memory storage
        final index = _webTargets.indexWhere((t) => t.id == target.id);
        if (index != -1) {
          _webTargets[index] = updatedTarget;
        }
      }
    }
    
    // Queue for Firebase sync
    await _syncService.queueForSync(_collectionName, target.id, _toMap(updatedTarget));
    
    return updatedTarget;
  }

  // Delete study target (soft delete)
  Future<void> deleteStudyTarget(String id) async {
    final now = DateTime.now();
    
    if (kIsWeb) {
      // Use in-memory storage for web
      final index = _webTargets.indexWhere((t) => t.id == id);
      if (index != -1) {
        final target = _webTargets[index];
        _webTargets[index] = target.copyWith(
          isDeleted: true,
          updatedAt: now,
        );
      }
    } else {
      // Use SQLite for mobile
      try {
        final db = await SQLiteDatabase.database;
        await db.update(
          _tableName,
          {
            'is_deleted': 1,
            'updated_at': now.millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (e) {
        print('SQLite error: $e');
        // Fallback to in-memory storage
        final index = _webTargets.indexWhere((t) => t.id == id);
        if (index != -1) {
          final target = _webTargets[index];
          _webTargets[index] = target.copyWith(
            isDeleted: true,
            updatedAt: now,
          );
        }
      }
    }
    
    // Queue for Firebase sync
    await _syncService.queueForSync(_collectionName, id, {
      'is_deleted': true,
      'updated_at': now.millisecondsSinceEpoch,
    });
  }

  // Update current value of study target
  Future<StudyTarget> updateCurrentValue(String id, double currentValue) async {
    final target = await getStudyTarget(id);
    if (target == null) {
      throw Exception('Study target not found');
    }

    final updatedTarget = target.copyWith(
      currentValue: currentValue,
      isCompleted: currentValue >= target.targetValue,
    );

    return await updateStudyTarget(updatedTarget);
  }

  // Get completed study targets
  Future<List<StudyTarget>> getCompletedTargets(String userId) async {
    if (kIsWeb) {
      // Use in-memory storage for web
      return _webTargets
          .where((target) => 
            target.userId == userId && 
            target.isCompleted && 
            !target.isDeleted)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } else {
      // Use SQLite for mobile
      try {
        final db = await SQLiteDatabase.database;
        final results = await db.query(
          _tableName,
          where: 'user_id = ? AND is_completed = 1 AND is_deleted = 0',
          whereArgs: [userId],
          orderBy: 'updated_at DESC',
        );
        
        return results.map((row) => _fromMap(row)).toList();
      } catch (e) {
        print('SQLite error: $e');
        // Fallback to in-memory storage
        return _webTargets
            .where((target) => 
              target.userId == userId && 
              target.isCompleted && 
              !target.isDeleted)
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
    }
  }

  // Get active study targets
  Future<List<StudyTarget>> getActiveTargets(String userId) async {
    if (kIsWeb) {
      // Use in-memory storage for web
      return _webTargets
          .where((target) => 
            target.userId == userId && 
            !target.isCompleted && 
            !target.isDeleted)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      // Use SQLite for mobile
      try {
        final db = await SQLiteDatabase.database;
        final results = await db.query(
          _tableName,
          where: 'user_id = ? AND is_completed = 0 AND is_deleted = 0',
          whereArgs: [userId],
          orderBy: 'created_at DESC',
        );
        
        return results.map((row) => _fromMap(row)).toList();
      } catch (e) {
        print('SQLite error: $e');
        // Fallback to in-memory storage
        return _webTargets
            .where((target) => 
              target.userId == userId && 
              !target.isCompleted && 
              !target.isDeleted)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    }
  }

  // Get overdue study targets
  Future<List<StudyTarget>> getOverdueTargets(String userId) async {
    final targets = await getActiveTargets(userId);
    return targets.where((target) => target.isOverdue).toList();
  }

  // Sync from Firebase
  Future<void> syncFromFirebase(List<Map<String, dynamic>> firebaseData) async {
    for (final data in firebaseData) {
      final target = StudyTarget.fromJson(data);
      final existing = await getStudyTarget(target.id);
      
      if (existing != null) {
        // Update existing
        if (kIsWeb) {
          final index = _webTargets.indexWhere((t) => t.id == target.id);
          if (index != -1) {
            _webTargets[index] = target;
          }
        } else {
          try {
            final db = await SQLiteDatabase.database;
            await db.update(
              _tableName,
              _toMap(target),
              where: 'id = ?',
              whereArgs: [target.id],
            );
          } catch (e) {
            print('SQLite error: $e');
            // Fallback to in-memory storage
            final index = _webTargets.indexWhere((t) => t.id == target.id);
            if (index != -1) {
              _webTargets[index] = target;
            }
          }
        }
      } else {
        // Insert new
        if (kIsWeb) {
          _webTargets.add(target);
        } else {
          try {
            final db = await SQLiteDatabase.database;
            await db.insert(_tableName, _toMap(target));
          } catch (e) {
            print('SQLite error: $e');
            // Fallback to in-memory storage
            _webTargets.add(target);
          }
        }
      }
    }
  }

  // Get unsynced data for Firebase
  Future<List<Map<String, dynamic>>> getUnsyncedData() async {
    // For web, we don't track sync status in memory, so return empty
    if (kIsWeb) {
      return [];
    } else {
      try {
        final db = await SQLiteDatabase.database;
        final results = await db.query(
          _tableName,
          where: 'is_synced = 0 OR is_synced IS NULL',
        );
        
        return results.map((row) => _toMap(_fromMap(row))).toList();
      } catch (e) {
        print('SQLite error: $e');
        return [];
      }
    }
  }

  // Helper methods for SQLite conversion
  Map<String, dynamic> _toMap(StudyTarget target) {
    return {
      'id': target.id,
      'user_id': target.userId,
      'title': target.title,
      'description': target.description,
      'target_type': target.targetType,
      'target_value': target.targetValue,
      'current_value': target.currentValue,
      'unit': target.unit,
      'start_date': target.startDate?.millisecondsSinceEpoch,
      'end_date': target.endDate?.millisecondsSinceEpoch,
      'is_completed': target.isCompleted ? 1 : 0,
      'created_at': target.createdAt.millisecondsSinceEpoch,
      'updated_at': target.updatedAt.millisecondsSinceEpoch,
      'is_deleted': target.isDeleted ? 1 : 0,
      'is_synced': 0, // Will be updated by sync service
    };
  }

  StudyTarget _fromMap(Map<String, dynamic> map) {
    return StudyTarget(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'] ?? '',
      targetType: map['target_type'],
      targetValue: map['target_value']?.toDouble() ?? 0.0,
      currentValue: map['current_value']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      startDate: map['start_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int)
          : DateTime.now(),
      endDate: map['end_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int)
          : null,
      isCompleted: map['is_completed'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      isDeleted: map['is_deleted'] == 1,
    );
  }

  // Sync dữ liệu từ local storage lên Firebase
  Future<void> syncLocalToFirebase() async {
    try {
      print('🔄 StudyTargetRepository: Bắt đầu sync local to Firebase...');
      
      final localTargets = await StudyTargetLocalStorage.getStudyTargets();
      final lastSyncTime = await StudyTargetLocalStorage.getLastSyncTime();
      
      if (localTargets.isEmpty) {
        print('📱 StudyTargetRepository: Không có dữ liệu local để sync');
        return;
      }

      print('📱 StudyTargetRepository: Tìm thấy ${localTargets.length} study targets trong local storage');
      
      for (final target in localTargets) {
        try {
          // Kiểm tra xem target đã tồn tại trên Firebase chưa
          final existingDoc = await _firestore.collection(_collectionName).doc(target.id).get();
          
          if (!existingDoc.exists) {
            // Nếu chưa tồn tại, thêm mới
            await _firestore.collection(_collectionName).doc(target.id).set(_toMap(target));
            print('✅ StudyTargetRepository: Đã sync study target "${target.title}" lên Firebase');
          } else {
            // Nếu đã tồn tại, kiểm tra xem có cần cập nhật không
            final firebaseTarget = StudyTarget.fromFirebaseJson(existingDoc.data()!);
            if (target.updatedAt != null && 
                (firebaseTarget.updatedAt == null || 
                 target.updatedAt!.isAfter(firebaseTarget.updatedAt!))) {
              await _firestore.collection(_collectionName).doc(target.id).update(_toMap(target));
              print('✅ StudyTargetRepository: Đã cập nhật study target "${target.title}" trên Firebase');
            }
          }
        } catch (e) {
          print('⚠️ StudyTargetRepository: Lỗi khi sync study target "${target.title}": $e');
        }
      }
      
      print('✅ StudyTargetRepository: Hoàn thành sync local to Firebase');
    } catch (e) {
      print('❌ StudyTargetRepository: Lỗi khi sync local to Firebase: $e');
    }
  }
} 