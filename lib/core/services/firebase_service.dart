import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;
  
  // Khởi tạo Firebase
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      _firestore = FirebaseFirestore.instance;
      
      // Cấu hình Firestore settings cho development
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        sslEnabled: true,
      );
      
      print("✅ Firebase đã được khởi tạo thành công");
      print("📊 Firebase project: ${_firestore!.app.name}");
      print("📊 Firestore instance: ${_firestore!.app.options.projectId}");
      
      // Test connection
      try {
        await _firestore!.collection('tasks').limit(1).get();
        print("✅ Firestore connection test thành công");
      } catch (e) {
        print("❌ Firestore connection test failed: $e");
      }
    } catch (e) {
      print("❌ Lỗi khởi tạo Firebase: $e");
      rethrow;
    }
  }
  
  // Get Firestore instance
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase chưa được khởi tạo. Gọi initializeFirebase() trước.');
    }
    return _firestore!;
  }
  
  // Kiểm tra kết nối
  static Future<bool> checkConnection() async {
    try {
      await _firestore!.collection('test').limit(1).get();
      return true;
    } catch (e) {
      print("❌ Lỗi kết nối Firebase: $e");
      return false;
    }
  }
  
  // Backup data
  static Future<Map<String, dynamic>> backupData() async {
    try {
      final tasks = await _firestore!.collection('tasks').get();
      final events = await _firestore!.collection('events').get();
      final users = await _firestore!.collection('users').get();
      
      return {
        'tasks': tasks.docs.map((doc) => doc.data()).toList(),
        'events': events.docs.map((doc) => doc.data()).toList(),
        'users': users.docs.map((doc) => doc.data()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print("❌ Lỗi backup data: $e");
      rethrow;
    }
  }
  
  // Restore data
  static Future<void> restoreData(Map<String, dynamic> backup) async {
    try {
      final batch = _firestore!.batch();
      
      // Restore tasks
      for (final task in backup['tasks']) {
        final docRef = _firestore!.collection('tasks').doc();
        batch.set(docRef, task);
      }
      
      // Restore events
      for (final event in backup['events']) {
        final docRef = _firestore!.collection('events').doc();
        batch.set(docRef, event);
      }
      
      // Restore users
      for (final user in backup['users']) {
        final docRef = _firestore!.collection('users').doc();
        batch.set(docRef, user);
      }
      
      await batch.commit();
      print("✅ Restore data thành công");
    } catch (e) {
      print("❌ Lỗi restore data: $e");
      rethrow;
    }
  }
} 