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
      print('🔄 UserNotifier: Starting to load current user...');
      final user = await _repository.getCurrentUser();
      
      if (user != null) {
        print('✅ UserNotifier: Load user successfully: ${user.displayName}');
        state = state.copyWith(
          user: user,
          consecutiveDays: user.consecutiveDays,
          isLoading: false,
        );
      } else {
        print('⚠️ UserNotifier: Cannot find user, user not authenticated');
        // Không tạo user mới khi không tìm thấy user
        state = state.copyWith(
          user: null,
          isLoading: false,
          errorMessage: 'User not authenticated',
        );
      }
    } catch (e) {
      print('❌ UserNotifier: Error loading user: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Cannot load user information: $e',
      );
    }
  }



  Future<void> updateConsecutiveDays() async {
    try {
      print('🔄 UserNotifier: Updating consecutive days...');
      await _repository.updateConsecutiveDays();
      
      // Reload user to get new information
      await loadCurrentUser();
    } catch (e) {
      print('❌ UserNotifier: Error updating consecutive days: $e');
    }
  }

  Future<int> getCurrentConsecutiveDays() async {
    try {
      final days = await _repository.getCurrentConsecutiveDays();
      state = state.copyWith(consecutiveDays: days);
      return days;
    } catch (e) {
        print('❌ UserNotifier: Error getting consecutive days: $e');
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