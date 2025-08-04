import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final int level;
  final int points;
  final int totalStudyTime; // in minutes
  final int completedTasks;
  final int totalTasks;
  final int achievements;
  final DateTime createdAt;
  final DateTime lastActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.level,
    required this.points,
    required this.totalStudyTime,
    required this.completedTasks,
    required this.totalTasks,
    required this.achievements,
    required this.createdAt,
    required this.lastActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      level: json['level'] as int,
      points: json['points'] as int,
      totalStudyTime: json['totalStudyTime'] as int,
      completedTasks: json['completedTasks'] as int,
      totalTasks: json['totalTasks'] as int,
      achievements: json['achievements'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActive: DateTime.parse(json['lastActive'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'level': level,
      'points': points,
      'totalStudyTime': totalStudyTime,
      'completedTasks': completedTasks,
      'totalTasks': totalTasks,
      'achievements': achievements,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    int? level,
    int? points,
    int? totalStudyTime,
    int? completedTasks,
    int? totalTasks,
    int? achievements,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      level: level ?? this.level,
      points: points ?? this.points,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
      completedTasks: completedTasks ?? this.completedTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      achievements: achievements ?? this.achievements,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  double get completionRate => totalTasks > 0 ? completedTasks / totalTasks : 0.0;

  @override
  List<Object?> get props => [
    id, name, email, avatar, level, points,
    totalStudyTime, completedTasks, totalTasks,
    achievements, createdAt, lastActive,
  ];
} 