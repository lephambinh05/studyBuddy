import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class RealtimeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Stream cho real-time tasks
  static Stream<QuerySnapshot> getTasksStream() {
    return _firestore
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Stream cho real-time events
  static Stream<QuerySnapshot> getEventsStream() {
    return _firestore
        .collection('events')
        .orderBy('startTime', descending: false)
        .snapshots();
  }
  
  // Stream cho user's tasks
  static Stream<QuerySnapshot> getUserTasksStream(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Stream cho user's events
  static Stream<QuerySnapshot> getUserEventsStream(String userId) {
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: false)
        .snapshots();
  }
  
  // Real-time task updates
  static Future<void> updateTaskRealTime(String taskId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print("✅ Cập nhật task real-time thành công");
    } catch (e) {
      print("❌ Lỗi cập nhật task real-time: $e");
      rethrow;
    }
  }
  
  // Real-time event updates
  static Future<void> updateEventRealTime(String eventId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print("✅ Cập nhật event real-time thành công");
    } catch (e) {
      print("❌ Lỗi cập nhật event real-time: $e");
      rethrow;
    }
  }
  
  // Live notifications
  static Stream<QuerySnapshot> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Create notification
  static Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
    String? relatedId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type ?? 'general',
        'relatedId': relatedId,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
      print("✅ Tạo notification thành công");
    } catch (e) {
      print("❌ Lỗi tạo notification: $e");
      rethrow;
    }
  }
  
  // Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': DateTime.now().toIso8601String(),
      });
      print("✅ Đánh dấu notification đã đọc");
    } catch (e) {
      print("❌ Lỗi đánh dấu notification: $e");
      rethrow;
    }
  }
  
  // Real-time presence
  static Future<void> updateUserPresence(String userId, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now().toIso8601String(),
      });
      print("✅ Cập nhật presence thành công");
    } catch (e) {
      print("❌ Lỗi cập nhật presence: $e");
      rethrow;
    }
  }
  
  // Live chat (nếu cần)
  static Stream<QuerySnapshot> getChatMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }
  
  // Send chat message
  static Future<void> sendChatMessage({
    required String chatId,
    required String userId,
    required String message,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'userId': userId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
      print("✅ Gửi tin nhắn thành công");
    } catch (e) {
      print("❌ Lỗi gửi tin nhắn: $e");
      rethrow;
    }
  }
  
  // Real-time task completion
  static Future<void> completeTaskRealTime(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'isCompleted': true,
        'completedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      // Tạo notification cho task completion
      final taskDoc = await _firestore.collection('tasks').doc(taskId).get();
      final taskData = taskDoc.data();
      if (taskData != null && taskData['userId'] != null) {
        await createNotification(
          userId: taskData['userId'],
          title: 'Hoàn thành bài tập!',
          message: 'Bạn đã hoàn thành: ${taskData['title']}',
          type: 'task_completion',
          relatedId: taskId,
        );
      }
      
      print("✅ Hoàn thành task real-time thành công");
    } catch (e) {
      print("❌ Lỗi hoàn thành task: $e");
      rethrow;
    }
  }
  
  // Real-time event reminder
  static Future<void> createEventReminder(String eventId, String userId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      final eventData = eventDoc.data();
      
      if (eventData != null) {
        await createNotification(
          userId: userId,
          title: 'Nhắc nhở sự kiện',
          message: 'Sự kiện sắp diễn ra: ${eventData['title']}',
          type: 'event_reminder',
          relatedId: eventId,
        );
      }
      
      print("✅ Tạo reminder event thành công");
    } catch (e) {
      print("❌ Lỗi tạo reminder: $e");
      rethrow;
    }
  }
  
  // Batch updates for performance
  static Future<void> batchUpdateTasks(List<Map<String, dynamic>> updates) async {
    try {
      final batch = _firestore.batch();
      
      for (final update in updates) {
        final docRef = _firestore.collection('tasks').doc(update['id']);
        batch.update(docRef, {
          ...update['data'],
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
      
      await batch.commit();
      print("✅ Batch update tasks thành công");
    } catch (e) {
      print("❌ Lỗi batch update: $e");
      rethrow;
    }
  }
  
  // Real-time sync status
  static Stream<DocumentSnapshot> getSyncStatusStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots();
  }
  
  // Update sync status
  static Future<void> updateSyncStatus(String userId, bool isSyncing) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isSyncing': isSyncing,
        'lastSyncAt': DateTime.now().toIso8601String(),
      });
      print("✅ Cập nhật sync status thành công");
    } catch (e) {
      print("❌ Lỗi cập nhật sync status: $e");
      rethrow;
    }
  }
} 