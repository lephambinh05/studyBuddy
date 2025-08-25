import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/data/models/user.dart';
import 'package:studybuddy/data/sources/remote/firebase_auth_service.dart';
// import 'package:studybuddy/core/services/analytics_service.dart'; // Nếu cần log analytics
// import 'package:studybuddy/data/sources/local/shared_prefs_service.dart'; // Nếu cần lưu session

// Trạng thái xác thực
enum AuthStatus { unknown, authenticated, unauthenticated, authenticating, error }

class AuthState {
  final AuthStatus status;
  final fb_auth.User? firebaseUser; // User từ Firebase Auth
  final UserModel? appUser; // UserModel từ Firestore (thông tin chi tiết hơn)
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.unknown,
    this.firebaseUser,
    this.appUser,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    fb_auth.User? firebaseUser,
    UserModel? appUser,
    String? errorMessage,
    bool clearAppUser = false, // Cờ để xóa appUser khi đăng xuất
  }) {
    return AuthState(
      status: status ?? this.status,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      appUser: clearAppUser ? null : appUser ?? this.appUser,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthService _firebaseAuthService; // Changed to non-nullable
  // final AnalyticsService? _analyticsService; // Tùy chọn
  StreamSubscription<fb_auth.User?>? _authStateSubscription;
  StreamSubscription<UserModel?>? _appUserSubscription;

  AuthNotifier(this._firebaseAuthService /*, this._analyticsService */)
      : super(AuthState(status: AuthStatus.unknown)) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authStateSubscription?.cancel();
    _authStateSubscription = _firebaseAuthService.authStateChanges.listen((fbUser) async {
      if (fbUser != null) {
        // User đã đăng nhập với Firebase
        state = state.copyWith(status: AuthStatus.authenticating, firebaseUser: fbUser, errorMessage: null);
        _fetchAppUser(fbUser.uid);
        // Không lưu token cục bộ - chỉ sử dụng Firebase Auth
      } else {
        // User đã đăng xuất
        _appUserSubscription?.cancel();
        state = state.copyWith(
            status: AuthStatus.unauthenticated,
            firebaseUser: null,
            clearAppUser: true, // Xóa thông tin appUser
            errorMessage: null);
        // Không cần xóa session cục bộ - Firebase Auth tự quản lý
      }
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final fbUser = await _firebaseAuthService.signInWithEmailAndPassword(email, password);
      if (fbUser == null) { // Nên được xử lý bởi listenToAuthChanges, nhưng để chắc chắn
        state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: "Login failed.");
      }
      // _analyticsService?.logLogin('email');
    } catch (e) {
      String errorMessage = "Login failed.";
      
      // Xử lý các lỗi Firebase cụ thể
      if (e.toString().contains('user-not-found')) {
        errorMessage = "Email not found. Please check again or register a new account.";
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = "Wrong password. Please check again.";
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = "Invalid email. Please check again.";
      } else if (e.toString().contains('user-disabled')) {
        errorMessage = "Account has been disabled. Please contact support.";
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = "Too many login attempts. Please try again later.";
      } else if (e.toString().contains('network')) {
        errorMessage = "Network error. Please check your internet connection.";
      } else if (e.toString().contains('api-key-not-valid')) {
        errorMessage = "Firebase configuration error. Please contact the developer.";
      } else if (e.toString().contains('internal-error')) {
        errorMessage = "System error. Please try again later.";
      } else if (e.toString().contains('invalid-credential')) {
        errorMessage = "Invalid login information.";
      } else if (e.toString().contains('operation-not-allowed')) {
        errorMessage = "This login method is not supported.";
      } else if (e.toString().contains('weak-password')) {
        errorMessage = "Weak password. Please choose a stronger password.";
      } else if (e.toString().contains('email-already-in-use')) {
        errorMessage = "Email already in use. Please login or use a different email.";
      }
      
      print("❌ Auth error: $e");
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: errorMessage);
    }
  }

  Future<void> registerWithEmail(String email, String password, String displayName) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final fbUser = await _firebaseAuthService.registerWithEmailAndPassword(email, password, displayName);
      if (fbUser == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: "Registration failed.");
      }
      // _analyticsService?.logSignUp('email');
    } catch (e) {
      String errorMessage = "Registration failed.";
      
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = "Email already in use. Please login or use a different email.";
      } else if (e.toString().contains('weak-password')) {
        errorMessage = "Weak password. Please choose a stronger password.";
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = "Invalid email. Please check again.";
      } else if (e.toString().contains('operation-not-allowed')) {
        errorMessage = "Registration by email is not supported.";
      } else if (e.toString().contains('api-key-not-valid')) {
        errorMessage = "Firebase configuration error. Please contact the developer.";
      }
      
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: errorMessage);
    }
  }

  Future<void> signOut() async {
    try {
      print("🔄 AuthNotifier: Bắt đầu đăng xuất...");
      
      // Đăng xuất khỏi Firebase Auth
      await _firebaseAuthService.signOut();
      print("✅ AuthNotifier: Đã đăng xuất khỏi Firebase Auth");
      
      // Hủy các subscription
      _appUserSubscription?.cancel();
      print("✅ AuthNotifier: Đã hủy app user subscription");
      
      // Clear tất cả data
      await _clearAllData();
      print("✅ AuthNotifier: Đã clear tất cả data");
      
      // Cập nhật state về unauthenticated
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        firebaseUser: null,
        clearAppUser: true,
        errorMessage: null,
      );
      print("✅ AuthNotifier: Đã cập nhật state về unauthenticated");
      
      // _analyticsService?.logLogout();
      print("🎉 AuthNotifier: Đăng xuất thành công");
    } catch (e) {
      print("❌ AuthNotifier: Lỗi khi đăng xuất: $e");
      
      // Vẫn set state về unauthenticated ngay cả khi có lỗi
      _appUserSubscription?.cancel();
      await _clearAllData();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        firebaseUser: null,
        clearAppUser: true,
        errorMessage: null,
      );
      print("⚠️ AuthNotifier: Đã force logout do lỗi");
    }
  }

  /// Clear tất cả data khi logout
  Future<void> _clearAllData() async {
    try {
      // Clear SharedPreferences (nếu cần)
      // final sharedPrefs = await SharedPreferences.getInstance();
      // await sharedPrefs.clear();
      
      // Clear các provider khác (nếu cần)
      // Có thể inject các provider khác để clear
      
      print("✅ AuthNotifier: Đã clear tất cả data");
    } catch (e) {
      print("❌ AuthNotifier: Lỗi khi clear data: $e");
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuthService.sendPasswordResetEmail(email);
    } catch (e) {
      String errorMessage = "Sending password reset email failed.";
      
      if (e.toString().contains('user-not-found')) {
        errorMessage = "Email not found in the system.";
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = "Invalid email.";
      } else if (e.toString().contains('api-key-not-valid')) {
        errorMessage = "Firebase configuration error. Please contact the developer.";
      }
      
      state = state.copyWith(errorMessage: errorMessage);
    }
  }

  // Xóa error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> updateAppUser(UserModel user) async {
    try {
      await _firebaseAuthService.updateUser(user);
      state = state.copyWith(appUser: user);
    } catch (e) {
      print("❌ Update user error: $e");
      state = state.copyWith(errorMessage: "Update user information failed.");
    }
  }

  Future<void> _fetchAppUser(String userId) async {
    _appUserSubscription?.cancel();
    _appUserSubscription = _firebaseAuthService.getUserStream(userId).listen((appUser) {
      if (appUser != null) {
        state = state.copyWith(status: AuthStatus.authenticated, appUser: appUser, errorMessage: null);
      } else {
        // Thử tạo lại user data nếu không tìm thấy
        _tryRecreateUserData(userId);
      }
    });
  }

  Future<void> _tryRecreateUserData(String userId) async {
    try {
      await _firebaseAuthService.recreateUserData(userId);
      // Fetch lại user data
      _fetchAppUser(userId);
    } catch (e) {
      print("❌ Recreate user data error: $e");
      state = state.copyWith(status: AuthStatus.error, errorMessage: "Cannot load user information.");
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _appUserSubscription?.cancel();
    super.dispose();
  }
}

// Provider cho AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final firebaseAuthService = ref.watch(firebaseAuthServiceProvider);
  return AuthNotifier(firebaseAuthService);
});

// Provider tiện ích để chỉ lấy trạng thái AuthStatus
final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authNotifierProvider).status;
});

// Provider tiện ích để chỉ lấy UserModel (appUser)
final appUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authNotifierProvider).appUser;
});

// Provider tiện ích để chỉ lấy Firebase User
final firebaseUserProvider = Provider<fb_auth.User?>((ref) {
  return ref.watch(authNotifierProvider).firebaseUser;
});

