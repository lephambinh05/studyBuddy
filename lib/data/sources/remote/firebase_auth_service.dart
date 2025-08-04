import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:studybuddy/data/models/user.dart';
import 'package:studybuddy/core/constants/app_constants.dart';

/// Service quản lý authentication hoàn toàn qua Firebase
/// Không lưu trữ bất kỳ thông tin authentication nào cục bộ
class FirebaseAuthService {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthService(this._firebaseAuth, this._firestore);

  CollectionReference<UserModel> get _usersCollection =>
      _firestore.collection(AppConstants.usersCollection).withConverter<UserModel>(
        fromFirestore: UserModel.fromFirestore,
        toFirestore: (UserModel user, _) => user.toFirestore(),
      );

  /// Stream theo dõi trạng thái authentication từ Firebase
  Stream<fb_auth.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  /// Lấy user hiện tại từ Firebase Auth
  fb_auth.User? get currentUser {
    return _firebaseAuth.currentUser;
  }

  /// Đăng ký với email và password
  Future<fb_auth.User?> registerWithEmailAndPassword(String email, String password, String displayName) async {
    fb_auth.User? firebaseUser;
    try {
      // Tạo user trong Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      firebaseUser = userCredential.user;
      
      if (firebaseUser != null) {
        // Cập nhật displayName cho Firebase Auth user
        await firebaseUser.updateDisplayName(displayName);
        
        // Tạo UserModel trong Firestore (không lưu cục bộ)
        final newUser = UserModel(
          id: firebaseUser.uid,
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: displayName,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        
        await _usersCollection.doc(firebaseUser.uid).set(newUser);
      }
      
      return firebaseUser;
    } on fb_auth.FirebaseAuthException catch (e) {
      print("FirebaseAuthException on register: ${e.message} (code: ${e.code})");
      
      // Rollback: xóa Firebase user nếu tạo Firestore user thất bại
      if (firebaseUser != null && e.code != 'email-already-in-use') {
        try {
          await firebaseUser.delete();
        } catch (deleteError) {
          print("Error deleting Firebase user after Firestore failure: $deleteError");
        }
      }
      
      throw Exception(e.message);
    } catch (e) {
      print("Error registering user: $e");
      
      // Rollback: xóa Firebase user nếu có lỗi khác
      if (firebaseUser != null) {
        try {
          await firebaseUser.delete();
        } catch (deleteError) {
          print("Error deleting Firebase user after general failure: $deleteError");
        }
      }
      
      rethrow;
    }
  }

  /// Đăng nhập với email và password
  Future<fb_auth.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      
      if (userCredential.user != null) {
        // Cập nhật lastLogin trong Firestore (không lưu cục bộ)
        await _usersCollection.doc(userCredential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp()
        });
      }
      
      return userCredential.user;
    } on fb_auth.FirebaseAuthException catch (e) {
      print("FirebaseAuthException on sign in: ${e.message} (code: ${e.code})");
      throw Exception(e.message);
    } catch (e) {
      print("Error signing in: $e");
      rethrow;
    }
  }

  /// Đăng xuất (chỉ sử dụng Firebase Auth)
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      // Không cần xóa dữ liệu cục bộ - Firebase Auth tự quản lý
    } catch (e) {
      print("Error signing out: $e");
      rethrow;
    }
  }

  /// Gửi email reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      print("FirebaseAuthException on password reset: ${e.message} (code: ${e.code})");
      throw Exception(e.message);
    } catch (e) {
      print("Error sending password reset email: $e");
      rethrow;
    }
  }

  /// Lấy thông tin user từ Firestore
  Stream<UserModel?> getUserStream(String userId) {
    if (userId.isEmpty) return Stream.value(null);
    return _usersCollection.doc(userId).snapshots().map((snapshot) => snapshot.data());
  }

  /// Lấy thông tin user từ Firestore (one-time)
  Future<UserModel?> getUser(String userId) async {
    if (userId.isEmpty) return null;
    final snapshot = await _usersCollection.doc(userId).get();
    return snapshot.data();
  }

  /// Cập nhật thông tin user trong Firestore
  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toFirestore());
    } catch (e) {
      print("Error updating user in Firestore: $e");
      rethrow;
    }
  }

  /// Tạo lại user data nếu bị thiếu
  Future<void> recreateUserData(String userId) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null && firebaseUser.uid == userId) {
        final newUser = UserModel(
          id: userId,
          uid: userId,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        await _usersCollection.doc(userId).set(newUser);
      }
    } catch (e) {
      print("Error recreating user data: $e");
      rethrow;
    }
  }

  /// Xóa user (cả Firebase Auth và Firestore)
  Future<void> deleteUser(String userId) async {
    try {
      // Xóa từ Firestore trước
      await _usersCollection.doc(userId).delete();
      
      // Xóa từ Firebase Auth (cần re-authentication)
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        await currentUser.delete();
      }
    } catch (e) {
      print("Error deleting user: $e");
      rethrow;
    }
  }
}

// Riverpod providers
final firebaseAuthProvider = Provider<fb_auth.FirebaseAuth>((ref) => fb_auth.FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
}); 