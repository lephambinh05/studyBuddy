import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/data/models/event_model.dart';
import 'package:studybuddy/data/repositories/event_repository.dart';

// Repository provider
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

// State cho events
class EventState {
  final List<EventModel> events;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> statistics;

  const EventState({
    this.events = const [],
    this.isLoading = false,
    this.error,
    this.statistics = const {},
  });

  EventState copyWith({
    List<EventModel>? events,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? statistics,
  }) {
    return EventState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statistics: statistics ?? this.statistics,
    );
  }
}

// Event provider
class EventNotifier extends StateNotifier<EventState> {
  final EventRepository _repository;

  EventNotifier(this._repository) : super(const EventState());

  // Load tất cả events
  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final events = await _repository.getAllEvents();
      final statistics = await _repository.getEventStatistics();
      
      state = state.copyWith(
        events: events,
        statistics: statistics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Load events theo tháng
  Future<void> loadEventsByMonth(DateTime month) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final events = await _repository.getEventsByMonth(month);
      
      state = state.copyWith(
        events: events,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Load events theo ngày
  Future<void> loadEventsByDate(DateTime date) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final events = await _repository.getEventsByDate(date);
      
      state = state.copyWith(
        events: events,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Thêm event mới
  Future<void> addEvent(EventModel event) async {
    try {
      await _repository.addEvent(event);
      await loadEvents(); // Reload để cập nhật UI
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Cập nhật event
  Future<void> updateEvent(String eventId, EventModel event) async {
    try {
      await _repository.updateEvent(eventId, event);
      await loadEvents(); // Reload để cập nhật UI
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Xóa event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _repository.deleteEvent(eventId);
      await loadEvents(); // Reload để cập nhật UI
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Clear all events (for demo purposes)
  void clearAllEvents() {
    state = state.copyWith(
      events: [],
      statistics: {
        'totalEvents': 0,
        'todayEvents': 0,
        'thisWeekEvents': 0,
      },
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Get event by ID
  EventModel? getEventById(String eventId) {
    try {
      return state.events.firstWhere((event) => event.id == eventId);
    } catch (e) {
      return null;
    }
  }

  // Get events by type
  List<EventModel> getEventsByType(String type) {
    return state.events.where((event) => event.type == type).toList();
  }

  // Get events by subject
  List<EventModel> getEventsBySubject(String subject) {
    return state.events.where((event) => event.subject == subject).toList();
  }

  // Get upcoming events
  List<EventModel> getUpcomingEvents({int days = 7}) {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    
    return state.events.where((event) => 
      event.startTime.isAfter(now) && event.startTime.isBefore(endDate)
    ).toList();
  }

  // Get today's events
  List<EventModel> getTodayEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return state.events.where((event) => 
      event.startTime.isAfter(today) && event.startTime.isBefore(tomorrow)
    ).toList();
  }
}

// Provider cho event state
final eventProvider = StateNotifierProvider<EventNotifier, EventState>((ref) {
  final repository = ref.watch(eventRepositoryProvider);
  return EventNotifier(repository);
});

// Provider cho filtered events
final filteredEventsProvider = Provider.family<List<EventModel>, Map<String, dynamic>>((ref, filters) {
  final eventState = ref.watch(eventProvider);
  List<EventModel> filteredEvents = eventState.events;

  // Filter by type
  if (filters['type'] != null && filters['type'].isNotEmpty) {
    filteredEvents = filteredEvents.where((event) => 
      event.type == filters['type']
    ).toList();
  }

  // Filter by subject
  if (filters['subject'] != null && filters['subject'].isNotEmpty) {
    filteredEvents = filteredEvents.where((event) => 
      event.subject == filters['subject']
    ).toList();
  }

  // Filter by date range
  if (filters['startDate'] != null) {
    filteredEvents = filteredEvents.where((event) => 
      event.startTime.isAfter(filters['startDate'])
    ).toList();
  }

  if (filters['endDate'] != null) {
    filteredEvents = filteredEvents.where((event) => 
      event.endTime.isBefore(filters['endDate'])
    ).toList();
  }

  return filteredEvents;
}); 