import 'package:json_annotation/json_annotation.dart';

part 'study_target.g.dart';

@JsonSerializable()
class StudyTarget {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String title;
  final String description;
  @JsonKey(name: 'target_type')
  final String targetType; // 'task_count', 'study_days', 'completion_rate', 'custom'
  @JsonKey(name: 'target_value')
  final double targetValue;
  @JsonKey(name: 'current_value')
  final double currentValue;
  final String unit; // 'tasks', 'days', '%', 'custom'
  @JsonKey(name: 'start_date', fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime startDate;
  @JsonKey(name: 'end_date', fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime? endDate;
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime updatedAt;
  @JsonKey(name: 'is_deleted')
  final bool isDeleted;

  StudyTarget({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.targetType,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.startDate,
    this.endDate,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory StudyTarget.fromJson(Map<String, dynamic> json) => _$StudyTargetFromJson(json);
  
  // Custom fromJson method for Firebase data
  factory StudyTarget.fromFirebaseJson(Map<String, dynamic> json) {
    return StudyTarget(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetType: json['target_type'] as String? ?? 'task_count',
      targetValue: (json['target_value'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'tasks',
      startDate: _dateTimeFromTimestamp(json['start_date']),
      endDate: json['end_date'] != null ? _dateTimeFromTimestamp(json['end_date']) : null,
      isCompleted: json['is_completed'] == 1 || json['is_completed'] == true,
      createdAt: _dateTimeFromTimestamp(json['created_at']),
      updatedAt: _dateTimeFromTimestamp(json['updated_at']),
      isDeleted: json['is_deleted'] == 1 || json['is_deleted'] == true,
    );
  }
  
  Map<String, dynamic> toJson() => _$StudyTargetToJson(this);

  // Helper methods for DateTime conversion
  static DateTime _dateTimeFromTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  static int _dateTimeToTimestamp(DateTime? dateTime) {
    return dateTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
  }

  // Helper methods
  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  bool get isOverdue => endDate != null && DateTime.now().isAfter(endDate!) && !isCompleted;
  int get daysRemaining {
    if (endDate == null) return -1;
    final now = DateTime.now();
    final remaining = endDate!.difference(now).inDays;
    return remaining > 0 ? remaining : 0;
  }

  // Copy with methods
  StudyTarget copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? targetType,
    double? targetValue,
    double? currentValue,
    String? unit,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return StudyTarget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  // Predefined target types
  static const String TASK_COUNT = 'task_count';
  static const String STUDY_DAYS = 'study_days';
  static const String COMPLETION_RATE = 'completion_rate';
  static const String CUSTOM = 'custom';

  // Predefined units
  static const String UNIT_TASKS = 'tasks';
  static const String UNIT_DAYS = 'days';
  static const String UNIT_PERCENT = '%';
  static const String UNIT_CUSTOM = 'custom';

  // Factory methods for common targets
  factory StudyTarget.taskCount({
    required String id,
    required String userId,
    required String title,
    required String description,
    required double targetValue,
    double currentValue = 0.0,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();
    return StudyTarget(
      id: id,
      userId: userId,
      title: title,
      description: description,
      targetType: TASK_COUNT,
      targetValue: targetValue,
      currentValue: currentValue,
      unit: UNIT_TASKS,
      startDate: startDate ?? now,
      endDate: endDate,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  factory StudyTarget.studyDays({
    required String id,
    required String userId,
    required String title,
    required String description,
    required double targetValue,
    double currentValue = 0.0,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();
    return StudyTarget(
      id: id,
      userId: userId,
      title: title,
      description: description,
      targetType: STUDY_DAYS,
      targetValue: targetValue,
      currentValue: currentValue,
      unit: UNIT_DAYS,
      startDate: startDate ?? now,
      endDate: endDate,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  factory StudyTarget.completionRate({
    required String id,
    required String userId,
    required String title,
    required String description,
    required double targetValue,
    double currentValue = 0.0,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();
    return StudyTarget(
      id: id,
      userId: userId,
      title: title,
      description: description,
      targetType: COMPLETION_RATE,
      targetValue: targetValue,
      currentValue: currentValue,
      unit: UNIT_PERCENT,
      startDate: startDate ?? now,
      endDate: endDate,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }
} 