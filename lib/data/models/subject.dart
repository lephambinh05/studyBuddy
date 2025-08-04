import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String id;
  final String name;
  final String? description;
  final String? color;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SubjectModel({
    required this.id,
    required this.name,
    this.description,
    this.color,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  factory SubjectModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, [SnapshotOptions? options]) {
    final data = snapshot.data();
    
    DateTime? _parseTimestamp(dynamic value) {
      if (value == null) return null;
      
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('⚠️ SubjectModel: Không thể parse timestamp string: $value');
          return null;
        }
      } else if (value is DateTime) {
        return value;
      }
      
      return null;
    }
    
    return SubjectModel(
      id: snapshot.id,
      name: data?['name'] as String? ?? '',
      description: data?['description'] as String?,
      color: data?['color'] as String?,
      userId: data?['userId'] as String? ?? '',
      createdAt: _parseTimestamp(data?['createdAt']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(data?['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  SubjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SubjectModel(id: $id, name: $name, description: $description, color: $color, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubjectModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.color == color &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        color.hashCode ^
        userId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
} 