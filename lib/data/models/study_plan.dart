import 'package:cloud_firestore/cloud_firestore.dart';

class StudyPlanModel {
  final String id;
  final String title;
  final String? description;
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> taskIds; // Danh sách ID của các task thuộc kế hoạch này
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudyPlanModel({
    required this.id,
    required this.title,
    this.description,
    required this.userId,
    this.startDate,
    this.endDate,
    this.taskIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory StudyPlanModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, [SnapshotOptions? options]) {
    final data = snapshot.data()!;
    return StudyPlanModel(
      id: snapshot.id,
      title: data['title'] as String,
      description: data['description'] as String?,
      userId: data['userId'] as String,
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      taskIds: List<String>.from(data['taskIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'userId': userId,
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      'taskIds': taskIds,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  StudyPlanModel copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? taskIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyPlanModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      taskIds: taskIds ?? this.taskIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
