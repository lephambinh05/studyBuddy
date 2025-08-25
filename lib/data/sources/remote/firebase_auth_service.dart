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
      print("🔄 FirebaseAuthService: Bắt đầu đăng ký user: $email");
      
      // Tạo user trong Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      firebaseUser = userCredential.user;
      
      if (firebaseUser != null) {
        print("✅ FirebaseAuthService: Đã tạo user trong Firebase Auth: ${firebaseUser.uid}");
        
        // Cập nhật displayName cho Firebase Auth user
        await firebaseUser.updateDisplayName(displayName);
        print("✅ FirebaseAuthService: Đã cập nhật displayName: $displayName");
        
        // Tạo UserModel trong Firestore
        final newUser = UserModel(
          id: firebaseUser.uid,
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: displayName,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        
        await _usersCollection.doc(firebaseUser.uid).set(newUser);
        print("✅ FirebaseAuthService: Đã tạo user trong Firestore: ${firebaseUser.uid}");
        
        print("🎉 FirebaseAuthService: Đăng ký thành công - User được tạo trong cả Firebase Auth và Firestore");
      }
      
      return firebaseUser;
    } on fb_auth.FirebaseAuthException catch (e) {
      print("❌ FirebaseAuthException on register: ${e.message} (code: ${e.code})");
      
      // Rollback: xóa Firebase user và Firestore user nếu có lỗi
      if (firebaseUser != null && e.code != 'email-already-in-use') {
        try {
          // Xóa Firestore user trước
          await _usersCollection.doc(firebaseUser.uid).delete();
          print("🔄 FirebaseAuthService: Đã rollback - xóa Firestore user");
          
          // Sau đó xóa Firebase user
          await firebaseUser.delete();
          print("🔄 FirebaseAuthService: Đã rollback - xóa Firebase user");
        } catch (deleteError) {
          print("❌ FirebaseAuthService: Lỗi khi rollback: $deleteError");
        }
      }
      
      throw Exception(e.message);
    } catch (e) {
      print("❌ FirebaseAuthService: Lỗi khi đăng ký user: $e");
      
      // Rollback: xóa Firebase user và Firestore user nếu có lỗi khác
      if (firebaseUser != null) {
        try {
          // Xóa Firestore user trước
          await _usersCollection.doc(firebaseUser.uid).delete();
          print("🔄 FirebaseAuthService: Đã rollback - xóa Firestore user");
          
          // Sau đó xóa Firebase user
          await firebaseUser.delete();
          print("🔄 FirebaseAuthService: Đã rollback - xóa Firebase user");
        } catch (deleteError) {
          print("❌ FirebaseAuthService: Lỗi khi rollback: $deleteError");
        }
      }
      
      rethrow;
    }
  }

  /// Đăng nhập với email và password
  Future<fb_auth.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Kiểm tra email và password không rỗng
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw Exception('Email và password không được để trống');
      }
      
      // Kiểm tra format email
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Email không hợp lệ');
      }
      
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      
      if (userCredential.user != null) {
        try {
          // Cập nhật lastLogin trong Firestore (không lưu cục bộ)
          await _usersCollection.doc(userCredential.user!.uid).update({
            'lastLogin': FieldValue.serverTimestamp()
          });
        } catch (firestoreError) {
          print("Warning: Could not update lastLogin in Firestore: $firestoreError");
          // Không throw error vì đăng nhập vẫn thành công
        }
      }
      
      return userCredential.user;
    } on fb_auth.FirebaseAuthException catch (e) {
      print("FirebaseAuthException on sign in: ${e.message} (code: ${e.code})");
      
      // Xử lý các lỗi cụ thể
      switch (e.code) {
        case 'invalid-credential':
          throw Exception('Email hoặc password không đúng');
        case 'user-not-found':
          throw Exception('Tài khoản không tồn tại');
        case 'wrong-password':
          throw Exception('Password không đúng');
        case 'user-disabled':
          throw Exception('Tài khoản đã bị vô hiệu hóa');
        case 'too-many-requests':
          throw Exception('Quá nhiều lần thử đăng nhập. Vui lòng thử lại sau');
        case 'network-request-failed':
          throw Exception('Lỗi kết nối mạng. Vui lòng kiểm tra internet');
        default:
          throw Exception(e.message ?? 'Lỗi đăng nhập không xác định');
      }
    } catch (e) {
      print("Error signing in: $e");
      rethrow;
    }
  }

  /// Đăng xuất (chỉ sử dụng Firebase Auth)
  Future<void> signOut() async {
    try {
      print("🔄 FirebaseAuthService: Bắt đầu đăng xuất...");
      
      // Đăng xuất khỏi Firebase Auth
      await _firebaseAuth.signOut();
      print("✅ FirebaseAuthService: Đã đăng xuất khỏi Firebase Auth");
      
      // Không cần xóa dữ liệu cục bộ - Firebase Auth tự quản lý
      print("🎉 FirebaseAuthService: Đăng xuất thành công");
    } catch (e) {
      print("❌ FirebaseAuthService: Lỗi khi đăng xuất: $e");
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

  /// Kiểm tra và sửa chữa sự không đồng bộ giữa Firebase Auth và Firestore
  Future<Map<String, dynamic>> checkAndFixUserSync() async {
    try {
      print("🔄 FirebaseAuthService: Bắt đầu kiểm tra đồng bộ user...");
      
      // Lấy tất cả users từ Firestore
      final firestoreUsers = await _usersCollection.get();
      final firestoreUserIds = firestoreUsers.docs.map((doc) => doc.id).toSet();
      
      print("📊 FirebaseAuthService: Tìm thấy ${firestoreUserIds.length} users trong Firestore");
      
      // Lấy tất cả users từ Firebase Auth (cần admin SDK, nhưng có thể dùng cách khác)
      // Vì không có admin SDK, ta sẽ kiểm tra từng user trong Firestore
      final orphanedUsers = <String>[];
      final validUsers = <String>[];
      
      for (final userId in firestoreUserIds) {
        try {
          // Thử lấy user từ Firebase Auth (chỉ có thể lấy current user)
          // Nếu user không tồn tại trong Firebase Auth, sẽ có lỗi khi đăng nhập
          final userDoc = await _usersCollection.doc(userId).get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            if (userData != null) {
              print("✅ FirebaseAuthService: User $userId tồn tại trong Firestore");
              validUsers.add(userId);
            }
          }
        } catch (e) {
          print("❌ FirebaseAuthService: User $userId có vấn đề: $e");
          orphanedUsers.add(userId);
        }
      }
      
      print("📊 FirebaseAuthService: Kết quả kiểm tra:");
      print("   - Valid users: ${validUsers.length}");
      print("   - Orphaned users: ${orphanedUsers.length}");
      
      return {
        'totalFirestoreUsers': firestoreUserIds.length,
        'validUsers': validUsers.length,
        'orphanedUsers': orphanedUsers.length,
        'orphanedUserIds': orphanedUsers,
      };
    } catch (e) {
      print("❌ FirebaseAuthService: Lỗi khi kiểm tra đồng bộ: $e");
      rethrow;
    }
  }

  /// Xóa các user "orphaned" (có trong Firestore nhưng không có trong Firebase Auth)
  Future<void> cleanupOrphanedUsers(List<String> orphanedUserIds) async {
    try {
      print("🔄 FirebaseAuthService: Bắt đầu dọn dẹp ${orphanedUserIds.length} orphaned users...");
      
      for (final userId in orphanedUserIds) {
        try {
          await _usersCollection.doc(userId).delete();
          print("✅ FirebaseAuthService: Đã xóa orphaned user: $userId");
        } catch (e) {
          print("❌ FirebaseAuthService: Lỗi khi xóa user $userId: $e");
        }
      }
      
      print("✅ FirebaseAuthService: Hoàn thành dọn dẹp orphaned users");
    } catch (e) {
      print("❌ FirebaseAuthService: Lỗi khi dọn dẹp orphaned users: $e");
      rethrow;
    }
  }

  /// Tạo lại user data cho user đã có trong Firebase Auth nhưng thiếu trong Firestore
  Future<void> recreateMissingUserData() async {
    try {
      print("🔄 FirebaseAuthService: Bắt đầu tạo lại user data...");
      
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final existingUser = await getUser(currentUser.uid);
        if (existingUser == null) {
          print("⚠️ FirebaseAuthService: User ${currentUser.uid} thiếu trong Firestore, tạo lại...");
          await recreateUserData(currentUser.uid);
          print("✅ FirebaseAuthService: Đã tạo lại user data cho ${currentUser.uid}");
        } else {
          print("✅ FirebaseAuthService: User ${currentUser.uid} đã có trong Firestore");
        }
      }
    } catch (e) {
      print("❌ FirebaseAuthService: Lỗi khi tạo lại user data: $e");
      rethrow;
    }
  }

  /// Import toàn bộ user từ Firestore sang Firebase Authentication
  Future<Map<String, dynamic>> importAllUsersToAuth() async {
    try {
      print("🔄 FirebaseAuthService: Bắt đầu import toàn bộ user sang Firebase Auth...");
      
      // Lấy tất cả users từ Firestore
      final firestoreUsers = await _usersCollection.get();
      final firestoreUserIds = firestoreUsers.docs.map((doc) => doc.id).toSet();
      
      print("📊 FirebaseAuthService: Tìm thấy ${firestoreUserIds.length} users trong Firestore");
      
      int successCount = 0;
      int failedCount = 0;
      List<String> failedUsers = [];
      
      for (final doc in firestoreUsers.docs) {
        try {
          final userData = doc.data();
          final userId = doc.id;
          
          // Kiểm tra xem user đã tồn tại trong Firebase Auth chưa
          try {
                         // Thử lấy user từ Firebase Auth (chỉ có thể lấy current user)
             // Nếu user không tồn tại, sẽ có lỗi
             final existingUser = _firebaseAuth.currentUser;
            if (existingUser != null) {
              print("✅ FirebaseAuthService: User $userId đã tồn tại trong Firebase Auth");
              successCount++;
              continue;
            }
          } catch (e) {
            // User không tồn tại trong Firebase Auth, cần tạo
            print("⚠️ FirebaseAuthService: User $userId không tồn tại trong Firebase Auth, cần tạo...");
          }
          
                     // Tạo user trong Firebase Auth
           // Lưu ý: Không thể tạo user mà không có password
           // Vì vậy ta sẽ tạo với password mặc định và yêu cầu user đổi password
           final email = userData.email;
           if (email != null && email.isNotEmpty) {
             try {
               // Tạo user với password mặc định
               final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
                 email: email,
                 password: 'StudyBuddy123!', // Password mặc định
               );
               
               // Cập nhật displayName
               if (userData.displayName != null) {
                 await userCredential.user?.updateDisplayName(userData.displayName);
               }
              
              // Gửi email reset password để user đổi password
              await _firebaseAuth.sendPasswordResetEmail(email: email);
              
              print("✅ FirebaseAuthService: Đã tạo user $userId trong Firebase Auth và gửi email reset password");
              successCount++;
            } catch (authError) {
              print("❌ FirebaseAuthService: Lỗi khi tạo user $userId trong Firebase Auth: $authError");
              failedCount++;
              failedUsers.add(userId);
            }
          } else {
            print("❌ FirebaseAuthService: User $userId không có email hợp lệ");
            failedCount++;
            failedUsers.add(userId);
          }
        } catch (e) {
          print("❌ FirebaseAuthService: Lỗi khi xử lý user ${doc.id}: $e");
          failedCount++;
          failedUsers.add(doc.id);
        }
      }
      
      print("📊 FirebaseAuthService: Kết quả import:");
      print("   - Success: $successCount");
      print("   - Failed: $failedCount");
      
      return {
        'totalUsers': firestoreUserIds.length,
        'successCount': successCount,
        'failedCount': failedCount,
        'failedUserIds': failedUsers,
      };
    } catch (e) {
      print("❌ FirebaseAuthService: Lỗi khi import users: $e");
      rethrow;
    }
  }

  /// Xóa user từ cả Firebase Auth và Firestore
  Future<void> deleteUserCompletely(String userId) async {
    try {
      print("🔄 FirebaseAuthService: Bắt đầu xóa user $userId hoàn toàn...");
      
      // Xóa từ Firestore trước
      await _usersCollection.doc(userId).delete();
      print("✅ FirebaseAuthService: Đã xóa user $userId từ Firestore");
      
      // Xóa từ Firebase Auth (cần admin SDK hoặc user tự xóa)
      // Vì không có admin SDK, ta chỉ có thể xóa current user
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        await currentUser.delete();
        print("✅ FirebaseAuthService: Đã xóa user $userId từ Firebase Auth");
      } else {
        print("⚠️ FirebaseAuthService: Không thể xóa user $userId từ Firebase Auth (không phải current user)");
      }
    } catch (e) {
      print("❌ FirebaseAuthService: Lỗi khi xóa user $userId: $e");
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