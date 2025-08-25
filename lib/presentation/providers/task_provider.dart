import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:studybuddy/data/models/task_model.dart';
import 'package:studybuddy/data/repositories/task_repository.dart';
import 'package:studybuddy/presentation/providers/auth_provider.dart';

// Repository provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

// State cho tasks
class TaskState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> statistics;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.statistics = const {},
  });

  TaskState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? statistics,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statistics: statistics ?? this.statistics,
    );
  }
}

// Task provider
final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repository, ref);
});

// Provider để lắng nghe auth state changes
final authStateProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authNotifierProvider).status;
});

// Task provider
class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;
  final Ref _ref;

  TaskNotifier(this._repository, this._ref) : super(const TaskState());

  // Load tasks
  Future<void> loadTasks() async {
    print('🔄 TaskProvider: Starting to load tasks...');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Kiểm tra xem có user đăng nhập không
      final authState = _ref.read(authNotifierProvider);
      if (authState.status != AuthStatus.authenticated) {
        print('⚠️ TaskProvider: User not authenticated, skipping task load');
        state = state.copyWith(
          tasks: [],
          statistics: {
            'totalTasks': 0,
            'completedTasks': 0,
            'pendingTasks': 0,
            'overdueTasks': 0,
            'completionRate': 0.0,
          },
          isLoading: false,
          error: null,
        );
        return;
      }
      
      print('📡 TaskProvider: Calling repository.getAllTasks()...');
      final tasks = await _repository.getAllTasks();
      print('✅ TaskProvider: Repository returned ${tasks.length} tasks');
      
      // Debug: In ra trạng thái của từng task
      for (final task in tasks) {
        print('📋 TaskProvider: Task "${task.title}" (ID: ${task.id}): isCompleted = ${task.isCompleted}');
      }
      
      print('📊 TaskProvider: Calling repository.getTaskStatistics()...');
      final statistics = await _repository.getTaskStatistics();
      print('✅ TaskProvider: Statistics: $statistics');
      
      // Debug: Kiểm tra completed tasks
      final completedTasks = tasks.where((task) => task.isCompleted).toList();
      print('📊 TaskProvider: Completed tasks count: ${completedTasks.length}');
      for (final task in completedTasks) {
        print('  - Completed: "${task.title}" (ID: ${task.id})');
      }
      
      state = state.copyWith(
        tasks: tasks,
        statistics: statistics,
        isLoading: false,
        error: null,
      );
      print('✅ TaskProvider: Updated state successfully. Tasks: ${tasks.length}');
    } catch (e) {
      print('❌ TaskProvider: Error loading tasks: $e');
      state = state.copyWith(
        tasks: [],
        statistics: {
          'totalTasks': 0,
          'completedTasks': 0,
          'pendingTasks': 0,
          'overdueTasks': 0,
          'completionRate': 0.0,
        },
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load tasks với filter
  Future<void> loadTasksWithFilter({
    String? subject,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final tasks = await _repository.getTasksByFilter(
        subject: subject,
        startDate: startDate,
        endDate: endDate,
      );
      
      state = state.copyWith(
        tasks: tasks,
        isLoading: false,
      );
    } catch (e) {
      print('❌ TaskProvider: Error loading tasks with filter: $e');
      state = state.copyWith(
        tasks: [], // Empty list thay vì mock data
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Thêm task mới
  Future<void> addTask(TaskModel task) async {
    try {
      await _repository.addTask(task);
      await loadTasks(); // Reload để cập nhật UI
    } catch (e) {
      print('❌ TaskProvider: Error adding task: $e');
      state = state.copyWith(error: e.toString());
      // Re-throw để UI có thể hiển thị thông báo
      rethrow;
    }
  }

  // Cập nhật task
  Future<void> updateTask(String taskId, TaskModel task) async {
    try {
      await _repository.updateTask(taskId, task);
      await loadTasks(); // Reload để cập nhật UI
    } catch (e) {
      print('❌ TaskProvider: Error updating task: $e');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Xóa task
  Future<void> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
      await loadTasks(); // Reload để cập nhật UI
    } catch (e) {
      print('❌ TaskProvider: Error deleting task: $e');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Toggle completion status
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    print('🔄 TaskProvider: Starting to toggle task completion');
    print('📋 TaskProvider: TaskID: $taskId, isCompleted: $isCompleted');

    try {
      print('📡 TaskProvider: Gọi repository.toggleTaskCompletion()...');
      print('📡 TaskProvider: Repository instance: $_repository');
      
      // Kiểm tra repository có null không
      if (_repository == null) {
        print('❌ TaskProvider: Repository is null!');
        throw Exception('Repository is null');
      }
      
      await _repository.toggleTaskCompletion(taskId, isCompleted);
      print('✅ TaskProvider: Repository toggled successfully!');

      print('🔄 TaskProvider: Reload tasks to update UI...');
      await loadTasks(); // Reload để cập nhật UI
      print('✅ TaskProvider: Reload tasks successfully!');
      
      // Debug: Kiểm tra task sau khi toggle
      final currentTasks = state.tasks;
      print('📊 TaskProvider: Total tasks after reload: ${currentTasks.length}');
      
      final updatedTask = currentTasks.firstWhere(
        (task) => task.id == taskId,
        orElse: () {
          print('❌ TaskProvider: Task not found after reload: $taskId');
          print('📊 TaskProvider: Available task IDs: ${currentTasks.map((t) => t.id).toList()}');
          throw Exception('Task not found: $taskId');
        },
      );
      print('📊 TaskProvider: Task sau toggle: "${updatedTask.title}" (ID: ${updatedTask.id}): isCompleted = ${updatedTask.isCompleted}');
      
      // Kiểm tra xem toggle có thành công không
      if (updatedTask.isCompleted == isCompleted) {
        print('✅ TaskProvider: Toggle completed successfully! isCompleted has been updated correctly');
      } else {
        print('❌ TaskProvider: Toggle failed!');
        print('📊 TaskProvider: Expected isCompleted: $isCompleted');
        print('📊 TaskProvider: Actual isCompleted: ${updatedTask.isCompleted}');
      }
    } catch (e) {
      print('❌ TaskProvider: Error toggling task completion: $e');
      print('📊 TaskProvider: Stack trace: ${StackTrace.current}');
      state = state.copyWith(error: e.toString());
      // Re-throw để UI có thể hiển thị thông báo
      rethrow;
    }
  }

  // Clear all tasks (for demo purposes)
  void clearAllTasks() {
    state = state.copyWith(
      tasks: [],
      statistics: {
        'totalTasks': 0,
        'completedTasks': 0,
        'pendingTasks': 0,
        'overdueTasks': 0,
        'completionRate': 0.0,
      },
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear tasks (khi user đăng xuất)
  void clearTasks() {
    print('🗑️ TaskProvider: Clear tasks...');
    state = state.copyWith(
      tasks: [],
      statistics: {
        'totalTasks': 0,
        'completedTasks': 0,
        'pendingTasks': 0,
        'overdueTasks': 0,
        'completionRate': 0.0,
      },
      error: null,
    );
  }

  // Get task by ID
  TaskModel? getTaskById(String taskId) {
    try {
      return state.tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // Get tasks by subject
  List<TaskModel> getTasksBySubject(String subject) {
    return state.tasks.where((task) => task.subject == subject).toList();
  }

  // Get completed tasks
  List<TaskModel> getCompletedTasks() {
    return state.tasks.where((task) => task.isCompleted).toList();
  }

  // Get pending tasks
  List<TaskModel> getPendingTasks() {
    return state.tasks.where((task) => !task.isCompleted).toList();
  }

  // Get overdue tasks
  List<TaskModel> getOverdueTasks() {
    final now = DateTime.now();
    return state.tasks.where((task) => 
      !task.isCompleted && task.deadline.isBefore(now)
    ).toList();
  }

  // Get tasks due today
  List<TaskModel> getTasksDueToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return state.tasks.where((task) => 
      task.deadline.isAfter(today) && task.deadline.isBefore(tomorrow)
    ).toList();
  }

  // Get task statistics
  Map<String, dynamic> getTaskStatistics() {
    try {
      return state.statistics;
    } catch (e) {
      return {
        'totalTasks': 0,
        'completedTasks': 0,
        'pendingTasks': 0,
        'overdueTasks': 0,
        'completionRate': 0.0,
      };
    }
  }

  // Sync dữ liệu từ local storage lên Firebase
  Future<void> syncLocalToFirebase() async {
    try {
      print('🔄 TaskNotifier: Starting sync local to Firebase...');
      await _repository.syncLocalToFirebase();
      
      // Reload tasks after sync
      await loadTasks();
      
      print('✅ TaskNotifier: Sync local to Firebase completed');
    } catch (e) {
      print('❌ TaskNotifier: Error syncing local to Firebase: $e');
      state = state.copyWith(
        error: 'Cannot sync data: $e',
      );
    }
  }
}

// Provider cho filtered tasks
final filteredTasksProvider = Provider.family<List<TaskModel>, Map<String, dynamic>>((ref, filters) {
  final taskState = ref.watch(taskProvider);
  List<TaskModel> filteredTasks = taskState.tasks;

  // Filter by subject
  if (filters['subject'] != null && filters['subject'].isNotEmpty) {
    filteredTasks = filteredTasks.where((task) => 
      task.subject == filters['subject']
    ).toList();
  }

  // Filter by completion status
  if (filters['isCompleted'] != null) {
    filteredTasks = filteredTasks.where((task) => 
      task.isCompleted == filters['isCompleted']
    ).toList();
  }

  // Filter by date range
  if (filters['startDate'] != null) {
    filteredTasks = filteredTasks.where((task) => 
      task.deadline.isAfter(filters['startDate'])
    ).toList();
  }

  if (filters['endDate'] != null) {
    filteredTasks = filteredTasks.where((task) => 
      task.deadline.isBefore(filters['endDate'])
    ).toList();
  }

  return filteredTasks;
});

