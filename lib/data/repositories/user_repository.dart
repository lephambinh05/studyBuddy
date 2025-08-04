import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studybuddy/data/models/user.dart';
import 'package:studybuddy/data/repositories/subject_repository.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SubjectRepository _subjectRepository = SubjectRepository();

  String? get _currentUserId => _auth.currentUser?.uid;

  // Lấy thông tin user hiện tại
  Future<UserModel?> getCurrentUser() async {
    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ UserRepository: Lỗi khi lấy user: $e');
      return null;
    }
  }

  // Tạo hoặc cập nhật user
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      print('🔄 UserRepository: Bắt đầu createOrUpdateUser()');
      print('👤 UserRepository: User ID: ${user.id}');
      
      await _firestore.collection('users').doc(user.id).set(user.toFirestore());
      
      print('✅ UserRepository: Đã tạo/cập nhật user thành công');
    } catch (e) {
      print('❌ UserRepository: Lỗi khi tạo/cập nhật user: $e');
      rethrow;
    }
  }

  // Cập nhật consecutive days khi user hoàn thành task
  Future<void> updateConsecutiveDays() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final user = await getCurrentUser();
      if (user == null) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      int newConsecutiveDays = user.consecutiveDays;
      DateTime? newLastTaskCompletionDate = user.lastTaskCompletionDate;

      if (user.lastTaskCompletionDate == null) {
        // Lần đầu hoàn thành task
        newConsecutiveDays = 1;
        newLastTaskCompletionDate = today;
      } else {
        final lastCompletion = DateTime(
          user.lastTaskCompletionDate!.year,
          user.lastTaskCompletionDate!.month,
          user.lastTaskCompletionDate!.day,
        );

        if (today.difference(lastCompletion).inDays == 1) {
          // Hoàn thành task ngày hôm qua, tăng streak
          newConsecutiveDays = user.consecutiveDays + 1;
          newLastTaskCompletionDate = today;
        } else if (today.difference(lastCompletion).inDays == 0) {
          // Đã hoàn thành task hôm nay rồi, giữ nguyên
          newLastTaskCompletionDate = user.lastTaskCompletionDate;
        } else {
          // Bỏ lỡ ngày, reset streak
          newConsecutiveDays = 1;
          newLastTaskCompletionDate = today;
        }
      }

      final updatedUser = user.copyWith(
        consecutiveDays: newConsecutiveDays,
        lastTaskCompletionDate: newLastTaskCompletionDate,
      );

      await createOrUpdateUser(updatedUser);
      print('✅ UserRepository: Cập nhật consecutive days: $newConsecutiveDays');
    } catch (e) {
      print('❌ UserRepository: Lỗi khi cập nhật consecutive days: $e');
      rethrow;
    }
  }

  // Lấy consecutive days hiện tại
  Future<int> getCurrentConsecutiveDays() async {
    final user = await getCurrentUser();
    return user?.consecutiveDays ?? 0;
  }

  // Cập nhật favorite subject của user
  Future<void> updateFavoriteSubject(String subjectId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      print('🔄 UserRepository: Bắt đầu updateFavoriteSubject()');
      print('👤 UserRepository: User ID: $userId');
      print('📚 UserRepository: Subject ID: $subjectId');
      
      final user = await getCurrentUser();
      if (user == null) return;

      final updatedUser = user.copyWith(favoriteSubjectId: subjectId);
      await createOrUpdateUser(updatedUser);
      
      print('✅ UserRepository: Đã cập nhật favorite subject thành công');
    } catch (e) {
      print('❌ UserRepository: Lỗi khi cập nhật favorite subject: $e');
      rethrow;
    }
  }

  // Lấy favorite subject ID của user
  Future<String?> getFavoriteSubjectId() async {
    final user = await getCurrentUser();
    return user?.favoriteSubjectId;
  }
}
