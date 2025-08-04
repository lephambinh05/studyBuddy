import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/data/models/event_model.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mock data cho testing
  List<EventModel> _mockEvents = [
    EventModel(
      id: '1',
      title: 'Học Toán',
      description: 'Ôn tập chương 3',
      startTime: DateTime.now().add(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 4)),
      type: 'study',
      subject: 'Toán',
      location: 'Thư viện',
      isAllDay: false,
      color: '#FF6B6B',
    ),
    EventModel(
      id: '2',
      title: 'Kiểm tra Văn',
      description: 'Kiểm tra 15 phút',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 8)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 8, minutes: 15)),
      type: 'exam',
      subject: 'Văn',
      location: 'Lớp 12A1',
      isAllDay: false,
      color: '#4ECDC4',
    ),
  ];

  // Lấy tất cả events
  Future<List<EventModel>> getAllEvents() async {
    try {
      final querySnapshot = await _firestore
          .collection('events')
          .orderBy('startTime', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return EventModel.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    } catch (e) {
      print('Firebase error: $e, returning empty list');
      return [];
    }
  }

  // Lấy events theo tháng
  Future<List<EventModel>> getEventsByMonth(DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('events')
          .where('startTime', isGreaterThanOrEqualTo: startOfMonth)
          .where('startTime', isLessThanOrEqualTo: endOfMonth)
          .orderBy('startTime')
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return EventModel.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    } catch (e) {
      // Filter mock data by month
      return _mockEvents.where((event) {
        return event.startTime.isAfter(DateTime(month.year, month.month, 1)) &&
               event.startTime.isBefore(DateTime(month.year, month.month + 1, 0));
      }).toList();
    }
  }

  // Lấy events theo ngày
  Future<List<EventModel>> getEventsByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('events')
          .where('startTime', isGreaterThanOrEqualTo: startOfDay)
          .where('startTime', isLessThanOrEqualTo: endOfDay)
          .orderBy('startTime')
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return EventModel.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    } catch (e) {
      // Filter mock data by date
      return _mockEvents.where((event) {
        return event.startTime.isAfter(DateTime(date.year, date.month, date.day)) &&
               event.startTime.isBefore(DateTime(date.year, date.month, date.day + 1));
      }).toList();
    }
  }

  // Lấy event theo ID
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return EventModel.fromJson({
          'id': doc.id,
          ...data,
        });
      }
      return null;
    } catch (e) {
      try {
        return _mockEvents.firstWhere((event) => event.id == eventId);
      } catch (e) {
        return null;
      }
    }
  }

  // Thêm event mới
  Future<String> addEvent(EventModel event) async {
    try {
      final docRef = await _firestore.collection('events').add(event.toJson());
      return docRef.id;
    } catch (e) {
      final newEvent = event.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      _mockEvents.add(newEvent);
      return newEvent.id;
    }
  }

  // Cập nhật event
  Future<void> updateEvent(String eventId, EventModel event) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .update(event.toJson());
    } catch (e) {
      final index = _mockEvents.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _mockEvents[index] = event;
      }
    }
  }

  // Xóa event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      _mockEvents.removeWhere((event) => event.id == eventId);
    }
  }

  // Lấy events theo type
  Future<List<EventModel>> getEventsByType(String type) async {
    try {
      final querySnapshot = await _firestore
          .collection('events')
          .where('type', isEqualTo: type)
          .orderBy('startTime')
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return EventModel.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    } catch (e) {
      return _mockEvents.where((event) => event.type == type).toList();
    }
  }

  // Lấy upcoming events
  Future<List<EventModel>> getUpcomingEvents({int days = 7}) async {
    try {
      final now = DateTime.now();
      final endDate = now.add(Duration(days: days));

      final querySnapshot = await _firestore
          .collection('events')
          .where('startTime', isGreaterThanOrEqualTo: now)
          .where('startTime', isLessThanOrEqualTo: endDate)
          .orderBy('startTime')
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return EventModel.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    } catch (e) {
      final now = DateTime.now();
      final endDate = now.add(Duration(days: days));
      return _mockEvents.where((event) => 
        event.startTime.isAfter(now) && event.startTime.isBefore(endDate)
      ).toList();
    }
  }

  // Lấy thống kê events
  Future<Map<String, dynamic>> getEventStatistics() async {
    try {
      final querySnapshot = await _firestore.collection('events').get();
      final events = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return EventModel.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();

      return _calculateEventStatistics(events);
    } catch (e) {
      return _calculateEventStatistics(_mockEvents);
    }
  }

  Map<String, dynamic> _calculateEventStatistics(List<EventModel> events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.add(const Duration(days: 7));

    final totalEvents = events.length;
    final todayEvents = events
        .where((event) => event.startTime.isAfter(today) && 
                         event.startTime.isBefore(today.add(const Duration(days: 1))))
        .length;
    final thisWeekEvents = events
        .where((event) => event.startTime.isAfter(today) && 
                         event.startTime.isBefore(thisWeek))
        .length;

    return {
      'totalEvents': totalEvents,
      'todayEvents': todayEvents,
      'thisWeekEvents': thisWeekEvents,
    };
  }
} 