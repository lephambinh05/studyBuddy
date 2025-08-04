import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Các provider này đã được định nghĩa trong user_repository.dart hoặc có thể đặt ở đây
// final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
// final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);


class FirebaseService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseService(this._auth, this._firestore, this._storage);

  // Ví dụ về một hàm tiện ích chung
  Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
  }

  // TODO: Implement notification permissions when needed
  Future<void> requestNotificationPermissions() async {
    // Implementation will be added when firebase_messaging is added
  }

// Thêm các hàm tiện ích khác liên quan đến Firebase ở đây nếu cần
// Ví dụ: upload file to Firebase Storage, call a Cloud Function, etc.
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    ref.watch(firebaseStorageProvider),
  );
});
