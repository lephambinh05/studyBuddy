import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studybuddy/data/models/event_model.dart';
import 'package:studybuddy/data/sources/local/event_local_storage.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

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
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      print('🔄 EventRepository: Bắt đầu getAllEvents()');
      print('👤 EventRepository: User ID: $userId');
      
      // Thử lấy từ Firebase trước
      final querySnapshot = await _firestore
          .collection('events')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: false)
          .get();

      final events = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return EventModel.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();

      print('✅ EventRepository: Firebase trả về ${events.length} events cho user $userId');
      
      // Lưu vào local storage để backup
      await EventLocalStorage.saveEvents(events);
      
      return events;
    } catch (e) {
      print('❌ EventRepository: Lỗi khi lấy events từ Firebase: $e');
      print('🔄 EventRepository: Thử lấy từ local storage...');
      
      // Nếu Firebase lỗi, lấy từ local storage
      final localEvents = await EventLocalStorage.getEvents();
      print('📱 EventRepository: Local storage có ${localEvents.length} events');
      
      return localEvents;
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
      print('🔄 EventRepository: Bắt đầu addEvent()');
      print('📅 EventRepository: Event title: ${event.title}');
      
      // Thêm vào Firebase
      final docRef = await _firestore.collection('events').add(event.toJson());
      final newEvent = event.copyWith(id: docRef.id);
      
      // Lưu vào local storage để backup
      await EventLocalStorage.addEvent(newEvent);
      
      print('✅ EventRepository: Đã thêm event thành công với ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ EventRepository: Lỗi khi thêm event vào Firebase: $e');
      
      // Nếu Firebase lỗi, vẫn lưu vào local storage
      print('🔄 EventRepository: Lưu vào local storage để backup...');
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final tempEvent = event.copyWith(id: tempId);
      await EventLocalStorage.addEvent(tempEvent);
      
      print('📱 EventRepository: Đã lưu event vào local storage với ID tạm: $tempId');
      return tempId;
    }
  }

  // Cập nhật event
  Future<void> updateEvent(String eventId, EventModel event) async {
    try {
      print('🔄 EventRepository: Bắt đầu updateEvent()');
      print('📅 EventRepository: Event ID: $eventId, title: ${event.title}');
      
      final updatedEvent = event.copyWith(updatedAt: DateTime.now());
      
      // Cập nhật Firebase
      await _firestore
          .collection('events')
          .doc(eventId)
          .update(updatedEvent.toJson());
      
      // Cập nhật local storage
      await EventLocalStorage.updateEvent(eventId, updatedEvent);
      
      print('✅ EventRepository: Đã cập nhật event thành công');
    } catch (e) {
      print('❌ EventRepository: Lỗi khi cập nhật event trong Firebase: $e');
      
      // Nếu Firebase lỗi, vẫn cập nhật local storage
      print('🔄 EventRepository: Cập nhật local storage để backup...');
      final updatedEvent = event.copyWith(updatedAt: DateTime.now());
      await EventLocalStorage.updateEvent(eventId, updatedEvent);
      
      print('📱 EventRepository: Đã cập nhật event trong local storage');
    }
  }

  // Xóa event
  Future<void> deleteEvent(String eventId) async {
    try {
      print('🔄 EventRepository: Bắt đầu deleteEvent()');
      print('📅 EventRepository: Event ID: $eventId');
      
      // Xóa khỏi Firebase
      await _firestore.collection('events').doc(eventId).delete();
      
      // Xóa khỏi local storage
      await EventLocalStorage.deleteEvent(eventId);
      
      print('✅ EventRepository: Đã xóa event thành công');
    } catch (e) {
      print('❌ EventRepository: Lỗi khi xóa event khỏi Firebase: $e');
      
      // Nếu Firebase lỗi, vẫn xóa khỏi local storage
      print('🔄 EventRepository: Xóa khỏi local storage để backup...');
      await EventLocalStorage.deleteEvent(eventId);
      
      print('📱 EventRepository: Đã xóa event khỏi local storage');
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

  // Sync dữ liệu từ local storage lên Firebase
  Future<void> syncLocalToFirebase() async {
    try {
      print('🔄 EventRepository: Bắt đầu sync local to Firebase...');
      
      final localEvents = await EventLocalStorage.getEvents();
      final lastSyncTime = await EventLocalStorage.getLastSyncTime();
      
      if (localEvents.isEmpty) {
        print('📱 EventRepository: Không có dữ liệu local để sync');
        return;
      }

      print('📱 EventRepository: Tìm thấy ${localEvents.length} events trong local storage');
      
      for (final event in localEvents) {
        try {
          // Kiểm tra xem event đã tồn tại trên Firebase chưa
          final existingDoc = await _firestore.collection('events').doc(event.id).get();
          
          if (!existingDoc.exists) {
            // Nếu chưa tồn tại, thêm mới
            await _firestore.collection('events').doc(event.id).set(event.toJson());
            print('✅ EventRepository: Đã sync event "${event.title}" lên Firebase');
          } else {
            // Nếu đã tồn tại, kiểm tra xem có cần cập nhật không
            final firebaseEvent = EventModel.fromJson({
              'id': existingDoc.id,
              ...existingDoc.data()!,
            });
            if (event.updatedAt != null && 
                (firebaseEvent.updatedAt == null || 
                 event.updatedAt!.isAfter(firebaseEvent.updatedAt!))) {
              await _firestore.collection('events').doc(event.id).update(event.toJson());
              print('✅ EventRepository: Đã cập nhật event "${event.title}" trên Firebase');
            }
          }
        } catch (e) {
          print('⚠️ EventRepository: Lỗi khi sync event "${event.title}": $e');
        }
      }
      
      print('✅ EventRepository: Hoàn thành sync local to Firebase');
    } catch (e) {
      print('❌ EventRepository: Lỗi khi sync local to Firebase: $e');
    }
  }
} 