import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/data/repositories/user_repository.dart';
import 'package:studybuddy/data/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final int consecutiveDays;

  UserState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.consecutiveDays = 0,
  });

  UserState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    int? consecutiveDays,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(UserState());

  Future<void> loadCurrentUser() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      print('🔄 UserNotifier: Bắt đầu load current user...');
      final user = await _repository.getCurrentUser();
      
      if (user != null) {
        print('✅ UserNotifier: Load user thành công: ${user.displayName}');
        state = state.copyWith(
          user: user,
          consecutiveDays: user.consecutiveDays,
          isLoading: false,
        );
      } else {
        print('⚠️ UserNotifier: Không tìm thấy user, tạo user mới...');
        // Tạo user mới nếu chưa có
        await _createNewUser();
      }
    } catch (e) {
      print('❌ UserNotifier: Lỗi khi load user: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải thông tin người dùng: $e',
      );
    }
  }

  Future<void> _createNewUser() async {
    try {
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      
      if (currentUser != null) {
        final newUser = UserModel(
          id: currentUser.uid,
          uid: currentUser.uid,
          email: currentUser.email,
          displayName: currentUser.displayName,
          photoUrl: currentUser.photoURL,
          lastLogin: DateTime.now(),
          createdAt: DateTime.now(),
          consecutiveDays: 0,
        );

        await _repository.createOrUpdateUser(newUser);
        print('✅ UserNotifier: Đã tạo user mới: ${newUser.displayName}');
        
        state = state.copyWith(
          user: newUser,
          consecutiveDays: 0,
          isLoading: false,
        );
      }
    } catch (e) {
      print('❌ UserNotifier: Lỗi khi tạo user mới: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tạo người dùng mới: $e',
      );
    }
  }

  Future<void> updateConsecutiveDays() async {
    try {
      print('🔄 UserNotifier: Cập nhật consecutive days...');
      await _repository.updateConsecutiveDays();
      
      // Reload user để lấy thông tin mới
      await loadCurrentUser();
    } catch (e) {
      print('❌ UserNotifier: Lỗi khi cập nhật consecutive days: $e');
    }
  }

  Future<int> getCurrentConsecutiveDays() async {
    try {
      final days = await _repository.getCurrentConsecutiveDays();
      state = state.copyWith(consecutiveDays: days);
      return days;
    } catch (e) {
      print('❌ UserNotifier: Lỗi khi lấy consecutive days: $e');
      return 0;
    }
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository);
}); 