import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String type; // 'study', 'exam', 'assignment', 'other'
  final String? subject;
  final String? location;
  final bool isAllDay;
  final String color; // Hex color code
  final String? subjectId;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.subject,
    this.location,
    required this.isAllDay,
    required this.color,
    this.subjectId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      type: json['type'] as String,
      subject: json['subject'] as String?,
      location: json['location'] as String?,
      isAllDay: json['isAllDay'] as bool,
      color: json['color'] as String,
      subjectId: json['subjectId'] as String?,
      userId: json['userId'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type,
      'subject': subject,
      'location': location,
      'isAllDay': isAllDay,
      'color': color,
      'subjectId': subjectId,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? type,
    String? subject,
    String? location,
    bool? isAllDay,
    String? color,
    String? subjectId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      location: location ?? this.location,
      isAllDay: isAllDay ?? this.isAllDay,
      color: color ?? this.color,
      subjectId: subjectId ?? this.subjectId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, title, description, startTime, endTime,
    type, subject, location, isAllDay, color, subjectId, userId, createdAt, updatedAt,
  ];
} 