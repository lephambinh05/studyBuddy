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
      String errorMessage = "Đăng nhập thất bại";
      
      // Xử lý các lỗi Firebase cụ thể
      if (e.toString().contains('user-not-found')) {
        errorMessage = "Email không tồn tại. Vui lòng kiểm tra lại hoặc đăng ký tài khoản mới.";
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = "Mật khẩu không đúng. Vui lòng kiểm tra lại.";
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = "Email không hợp lệ. Vui lòng kiểm tra lại.";
      } else if (e.toString().contains('user-disabled')) {
        errorMessage = "Tài khoản đã bị vô hiệu hóa. Vui lòng liên hệ hỗ trợ.";
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = "Quá nhiều lần thử đăng nhập. Vui lòng thử lại sau.";
      } else if (e.toString().contains('network')) {
        errorMessage = "Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.";
      } else if (e.toString().contains('api-key-not-valid')) {
        errorMessage = "Lỗi cấu hình Firebase. Vui lòng liên hệ nhà phát triển.";
      } else if (e.toString().contains('internal-error')) {
        errorMessage = "Lỗi hệ thống. Vui lòng thử lại sau.";
      } else if (e.toString().contains('invalid-credential')) {
        errorMessage = "Thông tin đăng nhập không hợp lệ.";
      } else if (e.toString().contains('operation-not-allowed')) {
        errorMessage = "Phương thức đăng nhập này không được hỗ trợ.";
      } else if (e.toString().contains('weak-password')) {
        errorMessage = "Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.";
      } else if (e.toString().contains('email-already-in-use')) {
        errorMessage = "Email đã được sử dụng. Vui lòng đăng nhập hoặc sử dụng email khác.";
      }
      
      print("❌ Auth error: $e");
      state = state.copyWith(status: AuthStatus.error, errorMessage: errorMessage);
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
      String errorMessage = "Đăng ký thất bại";
      
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = "Email đã được sử dụng. Vui lòng đăng nhập hoặc sử dụng email khác.";
      } else if (e.toString().contains('weak-password')) {
        errorMessage = "Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.";
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = "Email không hợp lệ. Vui lòng kiểm tra lại.";
      } else if (e.toString().contains('operation-not-allowed')) {
        errorMessage = "Đăng ký bằng email không được hỗ trợ.";
      } else if (e.toString().contains('api-key-not-valid')) {
        errorMessage = "Lỗi cấu hình Firebase. Vui lòng liên hệ nhà phát triển.";
      }
      
      state = state.copyWith(status: AuthStatus.error, errorMessage: errorMessage);
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuthService.signOut();
      // _analyticsService?.logLogout();
    } catch (e) {
      print("❌ Sign out error: $e");
      // Vẫn set state về unauthenticated ngay cả khi có lỗi
      state = state.copyWith(
          status: AuthStatus.unauthenticated,
          firebaseUser: null,
          clearAppUser: true,
          errorMessage: null);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuthService.sendPasswordResetEmail(email);
    } catch (e) {
      String errorMessage = "Gửi email reset password thất bại";
      
      if (e.toString().contains('user-not-found')) {
        errorMessage = "Email không tồn tại trong hệ thống.";
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = "Email không hợp lệ.";
      } else if (e.toString().contains('api-key-not-valid')) {
        errorMessage = "Lỗi cấu hình Firebase. Vui lòng liên hệ nhà phát triển.";
      }
      
      state = state.copyWith(errorMessage: errorMessage);
    }
  }

  Future<void> updateAppUser(UserModel user) async {
    try {
      await _firebaseAuthService.updateUser(user);
      state = state.copyWith(appUser: user);
    } catch (e) {
      print("❌ Update user error: $e");
      state = state.copyWith(errorMessage: "Cập nhật thông tin thất bại");
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
      state = state.copyWith(status: AuthStatus.error, errorMessage: "Không thể tải thông tin người dùng");
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

