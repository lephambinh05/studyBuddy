import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studybuddy/data/models/task_model.dart';

class TaskLocalStorage {
  static const String _tasksKey = 'local_tasks';
  static const String _lastSyncKey = 'tasks_last_sync';

  // Lưu tasks vào local storage
  static Future<void> saveTasks(List<TaskModel> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = tasks.map((task) => {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'subjectId': task.subjectId,
        'deadline': task.deadline.toIso8601String(),
        'priority': task.priority,
        'status': task.status,
        'userId': task.userId,
        'createdAt': task.createdAt.toIso8601String(),
        'updatedAt': task.updatedAt?.toIso8601String(),
      }).toList();

      await prefs.setString(_tasksKey, jsonEncode(tasksJson));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      
      print('✅ TaskLocalStorage: Đã lưu ${tasks.length} tasks vào local storage');
    } catch (e) {
      print('❌ TaskLocalStorage: Lỗi khi lưu tasks: $e');
    }
  }

  // Lấy tasks từ local storage
  static Future<List<TaskModel>> getTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey);
      
      if (tasksJson == null) {
        print('⚠️ TaskLocalStorage: Không có dữ liệu tasks trong local storage');
        return [];
      }

      final List<dynamic> tasksList = jsonDecode(tasksJson);
      final tasks = tasksList.map((json) => TaskModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'],
        subject: json['subject'] ?? '',
        subjectId: json['subjectId'],
        deadline: DateTime.parse(json['deadline']),
        isCompleted: json['isCompleted'] ?? false,
        priority: json['priority'] ?? 2,
        createdAt: DateTime.parse(json['createdAt']),
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        userId: json['userId'] ?? '',
        status: json['status'] ?? 'pending',
      )).toList();

      print('✅ TaskLocalStorage: Đã lấy ${tasks.length} tasks từ local storage');
      return tasks;
    } catch (e) {
      print('❌ TaskLocalStorage: Lỗi khi lấy tasks: $e');
      return [];
    }
  }

  // Lưu một task mới
  static Future<void> addTask(TaskModel task) async {
    try {
      final tasks = await getTasks();
      tasks.add(task);
      await saveTasks(tasks);
      
      print('✅ TaskLocalStorage: Đã thêm task "${task.title}" vào local storage');
    } catch (e) {
      print('❌ TaskLocalStorage: Lỗi khi thêm task: $e');
    }
  }

  // Cập nhật task
  static Future<void> updateTask(String taskId, TaskModel updatedTask) async {
    try {
      final tasks = await getTasks();
      final index = tasks.indexWhere((t) => t.id == taskId);
      
      if (index != -1) {
        tasks[index] = updatedTask;
        await saveTasks(tasks);
        print('✅ TaskLocalStorage: Đã cập nhật task "${updatedTask.title}" trong local storage');
      } else {
        print('⚠️ TaskLocalStorage: Không tìm thấy task với ID: $taskId');
      }
    } catch (e) {
      print('❌ TaskLocalStorage: Lỗi khi cập nhật task: $e');
    }
  }

  // Xóa task
  static Future<void> deleteTask(String taskId) async {
    try {
      final tasks = await getTasks();
      tasks.removeWhere((t) => t.id == taskId);
      await saveTasks(tasks);
      
      print('✅ TaskLocalStorage: Đã xóa task với ID: $taskId khỏi local storage');
    } catch (e) {
      print('❌ TaskLocalStorage: Lỗi khi xóa task: $e');
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
      print('❌ TaskLocalStorage: Lỗi khi lấy thời gian sync: $e');
      return null;
    }
  }

  // Xóa tất cả dữ liệu local
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tasksKey);
      await prefs.remove(_lastSyncKey);
      
      print('✅ TaskLocalStorage: Đã xóa tất cả dữ liệu tasks local');
    } catch (e) {
      print('❌ TaskLocalStorage: Lỗi khi xóa dữ liệu: $e');
    }
  }
} 