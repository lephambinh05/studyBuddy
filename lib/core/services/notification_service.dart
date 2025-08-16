// import 'package:firebase_messaging/firebase_messaging.dart';  // Temporarily disabled
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // static final FirebaseMessaging _messaging = FirebaseMessaging.instance;  // Temporarily disabled
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Smart notification settings
  static bool _smartNotificationsEnabled = true;
  static bool _behaviorBasedNotificationsEnabled = true;
  static Map<String, dynamic> _userBehavior = {};
  static DateTime? _lastStudySession;
  static int _consecutiveStudyDays = 0;
  
  // Notification preferences
  static Map<String, bool> _notificationPreferences = {
    'task_reminders': true,
    'event_reminders': true,
    'achievement_notifications': true,
    'study_reminders': true,
    'motivational_messages': true,
    'deadline_warnings': true,
  };
  
  // Khởi tạo notification service
  static Future<void> initialize() async {
    try {
      print('🔄 NotificationService: Bắt đầu khởi tạo...');

      // Initialize timezone
      tz.initializeTimeZones();

      // Mobile platforms
      try {
        await _initializeLocalNotifications();
        // await _initializeFirebaseMessaging();  // Temporarily disabled

        // Start smart notification monitoring
        _startSmartNotificationMonitoring();

        print('✅ Notification service đã được khởi tạo');
      } catch (e) {
        print('❌ Error initializing notification service: $e');
        // Don't rethrow, let the app continue without notifications
      }
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      // Don't rethrow, let the app continue without notifications
    }
  }
  
  // Khởi tạo local notifications
  static Future<void> _initializeLocalNotifications() async {
    // Initialize timezone
    tz.initializeTimeZones();
    
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }
  
  // Khởi tạo Firebase Messaging
  static Future<void> _initializeFirebaseMessaging() async {
    // Temporarily disabled for iOS testing
    print('Firebase Messaging temporarily disabled for iOS testing');
    return;
    
    // Request permission for iOS
    // NotificationSettings settings = await _messaging.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );
    
    // print('User granted permission: ${settings.authorizationStatus}');
    
    // Get FCM token
    // String? token = await _messaging.getToken();  // Temporarily disabled
    // if (token != null) {  // Temporarily disabled
    //   print('FCM Token: $token');  // Temporarily disabled
    //   await _saveTokenToDatabase(token);  // Temporarily disabled
    // }  // Temporarily disabled
    
    // Listen for token refresh
    // _messaging.onTokenRefresh.listen((newToken) {  // Temporarily disabled
    //   print('FCM Token refreshed: $newToken');  // Temporarily disabled
    //   _saveTokenToDatabase(newToken);  // Temporarily disabled
    // });  // Temporarily disabled
    
    // Handle background messages
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);  // Temporarily disabled
    
    // Handle foreground messages
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessage);  // Temporarily disabled
    
    // Handle notification taps when app is opened from notification
    // FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);  // Temporarily disabled
  }
  
  // Save FCM token to database
  static Future<void> _saveTokenToDatabase(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'lastTokenUpdate': DateTime.now().toIso8601String(),
        });
        print("✅ FCM token saved to database");
      }
    } catch (e) {
      print("❌ Error saving FCM token: $e");
    }
  }
  
  // Handle background messages
  // static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {  // Temporarily disabled
  //   print("Handling background message: ${message.messageId}");  // Temporarily disabled
  //    // Temporarily disabled
  //   // Show local notification  // Temporarily disabled
  //   await _showLocalNotification(  // Temporarily disabled
  //     id: message.hashCode,  // Temporarily disabled
  //     title: message.notification?.title ?? 'StudyBuddy',  // Temporarily disabled
  //     body: message.notification?.body ?? '',  // Temporarily disabled
  //     payload: message.data.toString(),  // Temporarily disabled
  //   );  // Temporarily disabled
  // }  // Temporarily disabled
  
  // Handle foreground messages
  // static void _handleForegroundMessage(RemoteMessage message) {  // Temporarily disabled
  //   print("Handling foreground message: ${message.messageId}");  // Temporarily disabled
  //    // Temporarily disabled
  //   // Show local notification  // Temporarily disabled
  //   _showLocalNotification(  // Temporarily disabled
  //     id: message.hashCode,  // Temporarily disabled
  //     title: message.notification?.title ?? 'StudyBuddy',  // Temporarily disabled
  //     body: message.notification?.body ?? '',  // Temporarily disabled
  //     payload: message.data.toString(),  // Temporarily disabled
  //   );  // Temporarily disabled
  // }  // Temporarily disabled
  
  // Handle notification taps
  // static void _handleNotificationTap(RemoteMessage message) {  // Temporarily disabled
  //   print("Notification tapped: ${message.messageId}");  // Temporarily disabled
  //    // Temporarily disabled
  //   // Handle navigation based on message data  // Temporarily disabled
  //   final data = message.data;  // Temporarily disabled
  //   if (data['type'] == 'task_reminder') {  // Temporarily disabled
  //     // Navigate to task details  // Temporarily disabled
  //     print("Navigate to task: ${data['taskId']}");  // Temporarily disabled
  //   } else if (data['type'] == 'event_reminder') {  // Temporarily disabled
  //     // Navigate to event details  // Temporarily disabled
  //     print("Navigate to event: ${data['eventId']}");  // Temporarily disabled
  //   }  // Temporarily disabled
  // }  // Temporarily disabled
  
  // Show local notification
  static Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'studybuddy_channel',
      'StudyBuddy Notifications',
      channelDescription: 'Notifications for StudyBuddy app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      enableLights: true,
      color: Color(0xFF2196F3),
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
  
  // Handle local notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print("Local notification tapped: ${response.payload}");
    
    // Handle navigation based on payload
    if (response.payload != null) {
      // Parse payload and navigate accordingly
      print("Navigate based on payload: ${response.payload}");
    }
  }
  
  // Send notification to specific user
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final fcmToken = userData?['fcmToken'];
      
      if (fcmToken != null) {
        // Send via Cloud Functions (recommended) or direct FCM
        await _sendDirectNotification(
          token: fcmToken,
          title: title,
          body: body,
          data: data,
        );
      }
      
      // Also save to Firestore for in-app notifications
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      print("✅ Notification sent to user: $userId");
    } catch (e) {
      print("❌ Error sending notification: $e");
    }
  }
  
  // Send direct FCM notification (for testing)
  static Future<void> _sendDirectNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // This would typically be done via Cloud Functions
    // For now, we'll just log it
    print("Would send FCM notification to token: $token");
    print("Title: $title");
    print("Body: $body");
    print("Data: $data");
  }
  
  // Schedule local notification
  static Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'studybuddy_scheduled_channel',
      'StudyBuddy Scheduled Notifications',
      channelDescription: 'Scheduled notifications for StudyBuddy app',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    
    // Convert DateTime to TZDateTime
    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
    
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
    
    print("✅ Local notification scheduled for: $scheduledDate");
  }
  
  // Cancel scheduled notification
  static Future<void> cancelScheduledNotification(int id) async {
    await _localNotifications.cancel(id);
    print("✅ Scheduled notification cancelled: $id");
  }
  
  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    print("✅ All notifications cancelled");
  }
  
  // Get badge count
  static Future<int> getBadgeCount() async {
    return await _localNotifications.getNotificationAppLaunchDetails().then((details) {
      return details?.notificationResponse != null ? 1 : 0;
    });
  }
  
  // Clear badge
  static Future<void> clearBadge() async {
    await _localNotifications.cancelAll();
    print("✅ Badge cleared");
  }
  
  // Subscribe to topics
  static Future<void> subscribeToTopic(String topic) async {
    // await _messaging.subscribeToTopic(topic);  // Temporarily disabled
    print("✅ Subscribed to topic: $topic (Firebase Messaging disabled)");
  }
  
  // Unsubscribe from topics
  static Future<void> unsubscribeFromTopic(String topic) async {
    // await _messaging.unsubscribeFromTopic(topic);  // Temporarily disabled
    print("✅ Unsubscribed from topic: $topic (Firebase Messaging disabled)");
  }
  
  // Send task reminder
  static Future<void> sendTaskReminder({
    required String userId,
    required String taskId,
    required String taskTitle,
    required DateTime deadline,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'Nhắc nhở bài tập',
      body: 'Bài tập "$taskTitle" sắp đến hạn!',
      data: {
        'type': 'task_reminder',
        'taskId': taskId,
        'deadline': deadline.toIso8601String(),
      },
    );
  }
  
  // Send event reminder
  static Future<void> sendEventReminder({
    required String userId,
    required String eventId,
    required String eventTitle,
    required DateTime startTime,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'Nhắc nhở sự kiện',
      body: 'Sự kiện "$eventTitle" sắp diễn ra!',
      data: {
        'type': 'event_reminder',
        'eventId': eventId,
        'startTime': startTime.toIso8601String(),
      },
    );
  }
  
  // Send achievement notification
  static Future<void> sendAchievementNotification({
    required String userId,
    required String achievementTitle,
    required String achievementDescription,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: '🎉 Thành tích mới!',
      body: 'Bạn đã đạt được: $achievementTitle',
      data: {
        'type': 'achievement',
        'achievementTitle': achievementTitle,
        'achievementDescription': achievementDescription,
      },
    );
  }
  
  // ===== SMART NOTIFICATIONS =====
  
  // Load notification preferences
  static Future<void> _loadNotificationPreferences() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        final data = doc.data();
        if (data != null && data['notificationPreferences'] != null) {
          _notificationPreferences = Map<String, bool>.from(data['notificationPreferences']);
        }
      }
    } catch (e) {
      print('❌ Error loading notification preferences: $e');
    }
  }
  
  // Save notification preferences
  static Future<void> saveNotificationPreferences() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'notificationPreferences': _notificationPreferences,
        });
        print('✅ Notification preferences saved');
      }
    } catch (e) {
      print('❌ Error saving notification preferences: $e');
    }
  }
  
  // Update notification preference
  static Future<void> updateNotificationPreference(String key, bool value) async {
    _notificationPreferences[key] = value;
    await saveNotificationPreferences();
  }
  
  // Load user behavior data
  static Future<void> _loadUserBehavior() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        final data = doc.data();
        if (data != null) {
          _userBehavior = Map<String, dynamic>.from(data['userBehavior'] ?? {});
          _lastStudySession = data['lastStudySession'] != null 
              ? DateTime.parse(data['lastStudySession']) 
              : null;
          _consecutiveStudyDays = data['consecutiveStudyDays'] ?? 0;
        }
      }
    } catch (e) {
      print('❌ Error loading user behavior: $e');
    }
  }
  
  // Save user behavior data
  static Future<void> _saveUserBehavior() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'userBehavior': _userBehavior,
          'lastStudySession': _lastStudySession?.toIso8601String(),
          'consecutiveStudyDays': _consecutiveStudyDays,
        });
      }
    } catch (e) {
      print('❌ Error saving user behavior: $e');
    }
  }
  
  // Start smart notification monitoring
  static void _startSmartNotificationMonitoring() {
    // Monitor study sessions
    _monitorStudySessions();
    
    // Monitor task completion patterns
    _monitorTaskCompletionPatterns();
    
    // Monitor achievement progress
    _monitorAchievementProgress();
    
    // Schedule motivational messages
    _scheduleMotivationalMessages();
  }
  
  // Monitor study sessions
  static void _monitorStudySessions() {
    // Track when user starts studying
    _recordStudySession();
    
    // Check for study streaks
    _checkStudyStreak();
    
    // Send study reminders based on patterns
    _sendStudyReminders();
  }
  
  // Record study session
  static void _recordStudySession() {
    final now = DateTime.now();
    _lastStudySession = now;
    
    // Update consecutive days
    if (_lastStudySession != null) {
      final yesterday = DateTime.now().subtract(Duration(days: 1));
      if (_lastStudySession!.isAfter(yesterday)) {
        _consecutiveStudyDays++;
      } else {
        _consecutiveStudyDays = 1;
      }
    }
    
    _saveUserBehavior();
  }
  
  // Check study streak
  static void _checkStudyStreak() {
    if (_consecutiveStudyDays >= 7) {
      sendNotificationToUser(
        userId: _auth.currentUser?.uid ?? '',
        title: '🔥 Chuỗi học tập!',
        body: 'Bạn đã học liên tiếp $_consecutiveStudyDays ngày! Hãy tiếp tục!',
        data: {
          'type': 'study_streak',
          'days': _consecutiveStudyDays,
        },
      );
    }
  }
  
  // Send study reminders based on patterns
  static void _sendStudyReminders() {
    final now = DateTime.now();
    final lastSession = _lastStudySession;
    
    if (lastSession != null) {
      final hoursSinceLastSession = now.difference(lastSession).inHours;
      
      // If user hasn't studied for more than 24 hours
      if (hoursSinceLastSession > 24) {
        sendNotificationToUser(
          userId: _auth.currentUser?.uid ?? '',
          title: '📚 Nhắc nhở học tập',
          body: 'Đã ${hoursSinceLastSession} giờ kể từ lần học cuối. Hãy dành thời gian học tập!',
          data: {
            'type': 'study_reminder',
            'hoursSinceLastSession': hoursSinceLastSession,
          },
        );
      }
    }
  }
  
  // Monitor task completion patterns
  static void _monitorTaskCompletionPatterns() {
    // This would analyze user's task completion patterns
    // and send personalized notifications
  }
  
  // Monitor achievement progress
  static void _monitorAchievementProgress() {
    // This would track user's progress towards achievements
    // and send encouraging notifications
  }
  
  // Schedule motivational messages
  static void _scheduleMotivationalMessages() {
    // Schedule daily motivational messages
    _scheduleDailyMotivationalMessage();
    
    // Schedule weekly progress summaries
    _scheduleWeeklyProgressSummary();
  }
  
  // Schedule daily motivational message
  static void _scheduleDailyMotivationalMessage() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 8, 0); // 8 AM tomorrow
    
    scheduleLocalNotification(
      id: 1001,
      title: '🌅 Chào buổi sáng!',
      body: 'Hôm nay là một ngày mới để học tập và phát triển!',
      scheduledDate: tomorrow,
      payload: 'daily_motivation',
    );
  }
  
  // Schedule weekly progress summary
  static void _scheduleWeeklyProgressSummary() {
    final now = DateTime.now();
    final nextSunday = DateTime(now.year, now.month, now.day + (7 - now.weekday), 18, 0); // 6 PM Sunday
    
    scheduleLocalNotification(
      id: 1002,
      title: '📊 Tóm tắt tuần',
      body: 'Hãy xem lại những gì bạn đã đạt được trong tuần này!',
      scheduledDate: nextSunday,
      payload: 'weekly_summary',
    );
  }
  
  // ===== BEHAVIOR-BASED NOTIFICATIONS =====
  
  // Send behavior-based notification
  static Future<void> sendBehaviorBasedNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (!_behaviorBasedNotificationsEnabled) return;
    
    // Check if user is likely to be receptive to this notification
    if (_shouldSendNotification(type)) {
      await sendNotificationToUser(
        userId: userId,
        title: title,
        body: body,
        data: data,
      );
    }
  }
  
  // Determine if notification should be sent based on user behavior
  static bool _shouldSendNotification(String type) {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Don't send notifications during sleep hours (11 PM - 7 AM)
    if (hour >= 23 || hour < 7) {
      return false;
    }
    
    // Check user's notification preferences
    if (!(_notificationPreferences[type] ?? true)) {
      return false;
    }
    
    // Check if user is active (based on last study session)
    if (_lastStudySession != null) {
      final hoursSinceLastActivity = now.difference(_lastStudySession!).inHours;
      if (hoursSinceLastActivity < 2) {
        // User is active, more likely to engage
        return true;
      }
    }
    
    return true;
  }
  
  // Send deadline warning based on user behavior
  static Future<void> sendDeadlineWarning({
    required String userId,
    required String taskId,
    required String taskTitle,
    required DateTime deadline,
  }) async {
    final now = DateTime.now();
    final hoursUntilDeadline = deadline.difference(now).inHours;
    
    String title, body;
    
    if (hoursUntilDeadline <= 1) {
      title = '🚨 Deadline gấp!';
      body = 'Bài tập "$taskTitle" hết hạn trong ${hoursUntilDeadline} giờ!';
    } else if (hoursUntilDeadline <= 6) {
      title = '⚠️ Deadline sắp đến!';
      body = 'Bài tập "$taskTitle" hết hạn trong ${hoursUntilDeadline} giờ';
    } else if (hoursUntilDeadline <= 24) {
      title = '📅 Deadline ngày mai!';
      body = 'Bài tập "$taskTitle" hết hạn ngày mai';
    } else {
      title = '📝 Nhắc nhở bài tập';
      body = 'Bài tập "$taskTitle" hết hạn trong ${hoursUntilDeadline ~/ 24} ngày';
    }
    
    await sendBehaviorBasedNotification(
      userId: userId,
      type: 'deadline_warnings',
      title: title,
      body: body,
      data: {
        'type': 'deadline_warning',
        'taskId': taskId,
        'deadline': deadline.toIso8601String(),
        'hoursUntilDeadline': hoursUntilDeadline,
      },
    );
  }
  
  // Send motivational message based on user behavior
  static Future<void> sendMotivationalMessage({
    required String userId,
    required String message,
  }) async {
    await sendBehaviorBasedNotification(
      userId: userId,
      type: 'motivational_messages',
      title: '💪 Động lực học tập',
      body: message,
      data: {
        'type': 'motivational_message',
      },
    );
  }
  
  // Send personalized study reminder
  static Future<void> sendPersonalizedStudyReminder({
    required String userId,
  }) async {
    String message;
    
    if (_consecutiveStudyDays >= 7) {
      message = '🔥 Bạn đang có chuỗi học tập tuyệt vời! Hãy tiếp tục!';
    } else if (_consecutiveStudyDays >= 3) {
      message = '📚 Bạn đang học tập rất chăm chỉ! Hãy duy trì!';
    } else {
      message = '📖 Hãy dành thời gian học tập hôm nay!';
    }
    
    await sendBehaviorBasedNotification(
      userId: userId,
      type: 'study_reminders',
      title: '📚 Nhắc nhở học tập',
      body: message,
      data: {
        'type': 'study_reminder',
        'consecutiveDays': _consecutiveStudyDays,
      },
    );
  }
  
  // Enable/disable smart notifications
  static void setSmartNotificationsEnabled(bool enabled) {
    _smartNotificationsEnabled = enabled;
  }
  
  // Enable/disable behavior-based notifications
  static void setBehaviorBasedNotificationsEnabled(bool enabled) {
    _behaviorBasedNotificationsEnabled = enabled;
  }
  
  // Get notification preferences
  static Map<String, bool> getNotificationPreferences() {
    return Map.from(_notificationPreferences);
  }
  
  // Get user behavior data
  static Map<String, dynamic> getUserBehavior() {
    return Map.from(_userBehavior);
  }
} 