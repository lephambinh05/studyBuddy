import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studybuddy/data/models/subject.dart';

class SubjectLocalStorage {
  static const String _subjectsKey = 'local_subjects';
  static const String _lastSyncKey = 'subjects_last_sync';

  // Lưu subjects vào local storage
  static Future<void> saveSubjects(List<SubjectModel> subjects) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectsJson = subjects.map((subject) => {
        'id': subject.id,
        'name': subject.name,
        'description': subject.description,
        'color': subject.color,
        'userId': subject.userId,
        'createdAt': subject.createdAt.toIso8601String(),
        'updatedAt': subject.updatedAt?.toIso8601String(),
      }).toList();

      await prefs.setString(_subjectsKey, jsonEncode(subjectsJson));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      
      print('✅ SubjectLocalStorage: Đã lưu ${subjects.length} subjects vào local storage');
    } catch (e) {
      print('❌ SubjectLocalStorage: Lỗi khi lưu subjects: $e');
    }
  }

  // Lấy subjects từ local storage
  static Future<List<SubjectModel>> getSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectsJson = prefs.getString(_subjectsKey);
      
      if (subjectsJson == null) {
        print('⚠️ SubjectLocalStorage: Không có dữ liệu subjects trong local storage');
        return [];
      }

      final List<dynamic> subjectsList = jsonDecode(subjectsJson);
      final subjects = subjectsList.map((json) => SubjectModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'],
        color: json['color'],
        userId: json['userId'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      )).toList();

      print('✅ SubjectLocalStorage: Đã lấy ${subjects.length} subjects từ local storage');
      return subjects;
    } catch (e) {
      print('❌ SubjectLocalStorage: Lỗi khi lấy subjects: $e');
      return [];
    }
  }

  // Lưu một subject mới
  static Future<void> addSubject(SubjectModel subject) async {
    try {
      final subjects = await getSubjects();
      subjects.add(subject);
      await saveSubjects(subjects);
      
      print('✅ SubjectLocalStorage: Đã thêm subject "${subject.name}" vào local storage');
    } catch (e) {
      print('❌ SubjectLocalStorage: Lỗi khi thêm subject: $e');
    }
  }

  // Cập nhật subject
  static Future<void> updateSubject(String subjectId, SubjectModel updatedSubject) async {
    try {
      final subjects = await getSubjects();
      final index = subjects.indexWhere((s) => s.id == subjectId);
      
      if (index != -1) {
        subjects[index] = updatedSubject;
        await saveSubjects(subjects);
        print('✅ SubjectLocalStorage: Đã cập nhật subject "${updatedSubject.name}" trong local storage');
      } else {
        print('⚠️ SubjectLocalStorage: Không tìm thấy subject với ID: $subjectId');
      }
    } catch (e) {
      print('❌ SubjectLocalStorage: Lỗi khi cập nhật subject: $e');
    }
  }

  // Xóa subject
  static Future<void> deleteSubject(String subjectId) async {
    try {
      final subjects = await getSubjects();
      subjects.removeWhere((s) => s.id == subjectId);
      await saveSubjects(subjects);
      
      print('✅ SubjectLocalStorage: Đã xóa subject với ID: $subjectId khỏi local storage');
    } catch (e) {
      print('❌ SubjectLocalStorage: Lỗi khi xóa subject: $e');
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
      print('❌ SubjectLocalStorage: Lỗi khi lấy thời gian sync: $e');
      return null;
    }
  }

  // Xóa tất cả dữ liệu local
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_subjectsKey);
      await prefs.remove(_lastSyncKey);
      
      print('✅ SubjectLocalStorage: Đã xóa tất cả dữ liệu subjects local');
    } catch (e) {
      print('❌ SubjectLocalStorage: Lỗi khi xóa dữ liệu: $e');
    }
  }
} 