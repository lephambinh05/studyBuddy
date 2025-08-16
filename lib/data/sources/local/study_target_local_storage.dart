import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studybuddy/data/models/study_target.dart';

class StudyTargetLocalStorage {
  static const String _targetsKey = 'local_study_targets';
  static const String _lastSyncKey = 'study_targets_last_sync';

  // Lưu study targets vào local storage
  static Future<void> saveStudyTargets(List<StudyTarget> targets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final targetsJson = targets.map((target) => {
        'id': target.id,
        'user_id': target.userId,
        'title': target.title,
        'description': target.description,
        'target_type': target.targetType,
        'target_value': target.targetValue,
        'current_value': target.currentValue,
        'unit': target.unit,
        'start_date': target.startDate.millisecondsSinceEpoch,
        'end_date': target.endDate?.millisecondsSinceEpoch,
        'is_completed': target.isCompleted,
        'created_at': target.createdAt.millisecondsSinceEpoch,
        'updated_at': target.updatedAt.millisecondsSinceEpoch,
        'is_deleted': target.isDeleted,
      }).toList();

      await prefs.setString(_targetsKey, jsonEncode(targetsJson));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      
      print('✅ StudyTargetLocalStorage: Đã lưu ${targets.length} study targets vào local storage');
    } catch (e) {
      print('❌ StudyTargetLocalStorage: Lỗi khi lưu study targets: $e');
    }
  }

  // Lấy study targets từ local storage
  static Future<List<StudyTarget>> getStudyTargets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final targetsJson = prefs.getString(_targetsKey);
      
      if (targetsJson == null) {
        print('⚠️ StudyTargetLocalStorage: Không có dữ liệu study targets trong local storage');
        return [];
      }

      final List<dynamic> targetsList = jsonDecode(targetsJson);
      final targets = targetsList.map((json) => StudyTarget.fromFirebaseJson(json)).toList();

      print('✅ StudyTargetLocalStorage: Đã lấy ${targets.length} study targets từ local storage');
      return targets;
    } catch (e) {
      print('❌ StudyTargetLocalStorage: Lỗi khi lấy study targets: $e');
      return [];
    }
  }

  // Lưu một study target mới
  static Future<void> addStudyTarget(StudyTarget target) async {
    try {
      final targets = await getStudyTargets();
      targets.add(target);
      await saveStudyTargets(targets);
      
      print('✅ StudyTargetLocalStorage: Đã thêm study target "${target.title}" vào local storage');
    } catch (e) {
      print('❌ StudyTargetLocalStorage: Lỗi khi thêm study target: $e');
    }
  }

  // Cập nhật study target
  static Future<void> updateStudyTarget(String targetId, StudyTarget updatedTarget) async {
    try {
      final targets = await getStudyTargets();
      final index = targets.indexWhere((t) => t.id == targetId);
      
      if (index != -1) {
        targets[index] = updatedTarget;
        await saveStudyTargets(targets);
        print('✅ StudyTargetLocalStorage: Đã cập nhật study target "${updatedTarget.title}" trong local storage');
      } else {
        print('⚠️ StudyTargetLocalStorage: Không tìm thấy study target với ID: $targetId');
      }
    } catch (e) {
      print('❌ StudyTargetLocalStorage: Lỗi khi cập nhật study target: $e');
    }
  }

  // Xóa study target
  static Future<void> deleteStudyTarget(String targetId) async {
    try {
      final targets = await getStudyTargets();
      targets.removeWhere((t) => t.id == targetId);
      await saveStudyTargets(targets);
      
      print('✅ StudyTargetLocalStorage: Đã xóa study target với ID: $targetId khỏi local storage');
    } catch (e) {
      print('❌ StudyTargetLocalStorage: Lỗi khi xóa study target: $e');
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
      print('❌ StudyTargetLocalStorage: Lỗi khi lấy thời gian sync: $e');
      return null;
    }
  }

  // Xóa tất cả dữ liệu local
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_targetsKey);
      await prefs.remove(_lastSyncKey);
      
      print('✅ StudyTargetLocalStorage: Đã xóa tất cả dữ liệu study targets local');
    } catch (e) {
      print('❌ StudyTargetLocalStorage: Lỗi khi xóa dữ liệu: $e');
    }
  }
} 