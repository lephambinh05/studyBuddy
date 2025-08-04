import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Stream để lắng nghe thay đổi trạng thái đăng nhập
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // User hiện tại
  static User? get currentUser => _auth.currentUser;
  
  // Kiểm tra đã đăng nhập chưa
  static bool get isLoggedIn => currentUser != null;
  
  // Đăng ký với email/password
  static Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? grade,
    String? school,
  }) async {
    try {
      // Tạo user với Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Cập nhật display name
      await userCredential.user?.updateDisplayName(name);
      
      // Lưu thông tin user vào Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'name': name,
        'email': email,
        'grade': grade,
        'school': school,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
        'isActive': true,
      });
      
      print("✅ Đăng ký thành công: ${userCredential.user!.email}");
      return userCredential;
    } catch (e) {
      print("❌ Lỗi đăng ký: $e");
      rethrow;
    }
  }
  
  // Đăng nhập với email/password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Cập nhật lastLoginAt
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
      
      print("✅ Đăng nhập thành công: ${userCredential.user!.email}");
      return userCredential;
    } catch (e) {
      print("❌ Lỗi đăng nhập: $e");
      rethrow;
    }
  }
  
  // Đăng xuất
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("✅ Đăng xuất thành công");
    } catch (e) {
      print("❌ Lỗi đăng xuất: $e");
      rethrow;
    }
  }
  
  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("✅ Email reset password đã được gửi");
    } catch (e) {
      print("❌ Lỗi gửi email reset: $e");
      rethrow;
    }
  }
  
  // Cập nhật profile
  static Future<void> updateProfile({
    required String name,
    String? grade,
    String? school,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('Chưa đăng nhập');
      
      // Cập nhật display name
      await user.updateDisplayName(name);
      
      // Cập nhật thông tin trong Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'grade': grade,
        'school': school,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      print("✅ Cập nhật profile thành công");
    } catch (e) {
      print("❌ Lỗi cập nhật profile: $e");
      rethrow;
    }
  }
  
  // Lấy thông tin user từ Firestore
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print("❌ Lỗi lấy thông tin user: $e");
      return null;
    }
  }
  
  // Xóa tài khoản
  static Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('Chưa đăng nhập');
      
      // Xóa dữ liệu user trong Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Xóa tài khoản Firebase Auth
      await user.delete();
      
      print("✅ Xóa tài khoản thành công");
    } catch (e) {
      print("❌ Lỗi xóa tài khoản: $e");
      rethrow;
    }
  }
  
  // Đăng nhập với Google (nếu cần)
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Cần thêm google_sign_in package
      // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // if (googleUser == null) return null;
      
      // final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      // final credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth.accessToken,
      //   idToken: googleAuth.idToken,
      // );
      
      // return await _auth.signInWithCredential(credential);
      print("⚠️ Google Sign-In chưa được implement");
      return null;
    } catch (e) {
      print("❌ Lỗi đăng nhập Google: $e");
      return null;
    }
  }
} 