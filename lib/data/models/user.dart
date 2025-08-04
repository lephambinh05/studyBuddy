import 'package:cloud_firestore/cloud_firestore.dart'; // Nếu dùng Timestamp từ Firestore

class UserModel {
  final String id;
  final String uid; // Thêm uid để tương thích với Firebase Auth
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? creationTime; // Thêm creationTime cho profile screen
  final int consecutiveDays; // Thêm consecutive days
  final DateTime? lastTaskCompletionDate; // Thêm last task completion date
  final String? favoriteSubjectId; // Thêm subjectId yêu thích của user
  // Thêm các thuộc tính người dùng khác nếu cần
  // Ví dụ: String? fcmToken; List<String> enrolledCourseIds;

  UserModel({
    required this.id,
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.lastLogin,
    this.createdAt,
    this.creationTime,
    this.consecutiveDays = 0,
    this.lastTaskCompletionDate,
    this.favoriteSubjectId,
  });

  // Factory constructor để tạo UserModel từ Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, [SnapshotOptions? options]) {
    final data = snapshot.data();
    
    // Helper function để parse timestamp từ nhiều format
    DateTime? _parseTimestamp(dynamic value) {
      if (value == null) return null;
      
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('⚠️ UserModel: Không thể parse timestamp string: $value');
          return null;
        }
      } else if (value is DateTime) {
        return value;
      }
      
      return null;
    }
    
    return UserModel(
      id: snapshot.id,
      uid: data?['uid'] as String? ?? snapshot.id, // Fallback to id if uid not found
      email: data?['email'] as String?,
      displayName: data?['displayName'] as String?,
      photoUrl: data?['photoUrl'] as String?,
      lastLogin: _parseTimestamp(data?['lastLogin']),
      createdAt: _parseTimestamp(data?['createdAt']),
      creationTime: _parseTimestamp(data?['creationTime']),
      consecutiveDays: data?['consecutiveDays'] as int? ?? 0,
      lastTaskCompletionDate: _parseTimestamp(data?['lastTaskCompletionDate']),
      favoriteSubjectId: data?['favoriteSubjectId'] as String?,
      // TODO: Map các trường khác từ Firestore
    );
  }

  // Phương thức để chuyển UserModel thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
      if (email != null) "email": email,
      if (displayName != null) "displayName": displayName,
      if (photoUrl != null) "photoUrl": photoUrl,
      if (lastLogin != null) "lastLogin": Timestamp.fromDate(lastLogin!),
      if (createdAt != null) "createdAt": Timestamp.fromDate(createdAt!),
      if (creationTime != null) "creationTime": Timestamp.fromDate(creationTime!),
      "consecutiveDays": consecutiveDays,
      if (lastTaskCompletionDate != null) "lastTaskCompletionDate": Timestamp.fromDate(lastTaskCompletionDate!),
      if (favoriteSubjectId != null) "favoriteSubjectId": favoriteSubjectId,
      // TODO: Map các trường khác vào Firestore
    };
  }

  // Copy with (tiện ích để tạo bản sao với một vài thuộc tính thay đổi)
  UserModel copyWith({
    String? id,
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? creationTime,
    int? consecutiveDays,
    DateTime? lastTaskCompletionDate,
    String? favoriteSubjectId,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      creationTime: creationTime ?? this.creationTime,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      lastTaskCompletionDate: lastTaskCompletionDate ?? this.lastTaskCompletionDate,
      favoriteSubjectId: favoriteSubjectId ?? this.favoriteSubjectId,
    );
  }

  // Để dễ debug
  @override
  String toString() {
    return 'UserModel(id: $id, uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, lastLogin: $lastLogin, createdAt: $createdAt, creationTime: $creationTime, consecutiveDays: $consecutiveDays, lastTaskCompletionDate: $lastTaskCompletionDate, favoriteSubjectId: $favoriteSubjectId)';
  }

  // Override == and hashCode nếu bạn định so sánh các instance của UserModel
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.lastLogin == lastLogin &&
        other.createdAt == createdAt &&
        other.creationTime == creationTime &&
        other.consecutiveDays == consecutiveDays &&
        other.lastTaskCompletionDate == lastTaskCompletionDate &&
        other.favoriteSubjectId == favoriteSubjectId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    uid.hashCode ^
    email.hashCode ^
    displayName.hashCode ^
    photoUrl.hashCode ^
    lastLogin.hashCode ^
    createdAt.hashCode ^
    creationTime.hashCode ^
    consecutiveDays.hashCode ^
    lastTaskCompletionDate.hashCode ^
    favoriteSubjectId.hashCode;
  }
}
