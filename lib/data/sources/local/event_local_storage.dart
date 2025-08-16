import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studybuddy/data/models/event_model.dart';

class EventLocalStorage {
  static const String _eventsKey = 'local_events';
  static const String _lastSyncKey = 'events_last_sync';

  // Lưu events vào local storage
  static Future<void> saveEvents(List<EventModel> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = events.map((event) => {
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'startTime': event.startTime.toIso8601String(),
        'endTime': event.endTime.toIso8601String(),
        'subjectId': event.subjectId,
        'type': event.type,
        'userId': event.userId,
        'createdAt': event.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'updatedAt': event.updatedAt?.toIso8601String(),
      }).toList();

      await prefs.setString(_eventsKey, jsonEncode(eventsJson));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      
      print('✅ EventLocalStorage: Đã lưu ${events.length} events vào local storage');
    } catch (e) {
      print('❌ EventLocalStorage: Lỗi khi lưu events: $e');
    }
  }

  // Lấy events từ local storage
  static Future<List<EventModel>> getEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_eventsKey);
      
      if (eventsJson == null) {
        print('⚠️ EventLocalStorage: Không có dữ liệu events trong local storage');
        return [];
      }

      final List<dynamic> eventsList = jsonDecode(eventsJson);
      final events = eventsList.map((json) => EventModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'],
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        type: json['type'] ?? 'study',
        subject: json['subject'],
        location: json['location'],
        isAllDay: json['isAllDay'] ?? false,
        color: json['color'] ?? '#FF6B6B',
        subjectId: json['subjectId'],
        userId: json['userId'] ?? '',
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      )).toList();

      print('✅ EventLocalStorage: Đã lấy ${events.length} events từ local storage');
      return events;
    } catch (e) {
      print('❌ EventLocalStorage: Lỗi khi lấy events: $e');
      return [];
    }
  }

  // Lưu một event mới
  static Future<void> addEvent(EventModel event) async {
    try {
      final events = await getEvents();
      events.add(event);
      await saveEvents(events);
      
      print('✅ EventLocalStorage: Đã thêm event "${event.title}" vào local storage');
    } catch (e) {
      print('❌ EventLocalStorage: Lỗi khi thêm event: $e');
    }
  }

  // Cập nhật event
  static Future<void> updateEvent(String eventId, EventModel updatedEvent) async {
    try {
      final events = await getEvents();
      final index = events.indexWhere((e) => e.id == eventId);
      
      if (index != -1) {
        events[index] = updatedEvent;
        await saveEvents(events);
        print('✅ EventLocalStorage: Đã cập nhật event "${updatedEvent.title}" trong local storage');
      } else {
        print('⚠️ EventLocalStorage: Không tìm thấy event với ID: $eventId');
      }
    } catch (e) {
      print('❌ EventLocalStorage: Lỗi khi cập nhật event: $e');
    }
  }

  // Xóa event
  static Future<void> deleteEvent(String eventId) async {
    try {
      final events = await getEvents();
      events.removeWhere((e) => e.id == eventId);
      await saveEvents(events);
      
      print('✅ EventLocalStorage: Đã xóa event với ID: $eventId khỏi local storage');
    } catch (e) {
      print('❌ EventLocalStorage: Lỗi khi xóa event: $e');
    }
  }

  // Lấy thời gian sync cuối cùng
  static Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncString = prefs.getString(_lastSyncKey);
      
      if (lastSyncString != null) {
        return DateTime.parse(lastSyncString);
      }
      return null;
    } catch (e) {
      print('❌ EventLocalStorage: Lỗi khi lấy thời gian sync: $e');
      return null;
    }
  }

  // Xóa tất cả dữ liệu local
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_eventsKey);
      await prefs.remove(_lastSyncKey);
      
      print('✅ EventLocalStorage: Đã xóa tất cả dữ liệu events local');
    } catch (e) {
      print('❌ EventLocalStorage: Lỗi khi xóa dữ liệu: $e');
    }
  }
} 