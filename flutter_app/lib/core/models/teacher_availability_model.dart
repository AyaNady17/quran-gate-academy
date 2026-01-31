import 'package:equatable/equatable.dart';

/// Teacher availability model
class TeacherAvailabilityModel extends Equatable {
  final String id;
  final String teacherId;
  final String dayOfWeek; // 'Monday', 'Tuesday', etc.
  final String startTime; // e.g., "09:00"
  final String endTime; // e.g., "17:00"
  final bool isAvailable;
  final String? timezone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TeacherAvailabilityModel({
    required this.id,
    required this.teacherId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.timezone,
    required this.createdAt,
    this.updatedAt,
  });

  factory TeacherAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return TeacherAvailabilityModel(
      id: json['\$id'] ?? '',
      teacherId: json['teacherId'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      timezone: json['timezone'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  TeacherAvailabilityModel copyWith({
    String? id,
    String? teacherId,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isAvailable,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherAvailabilityModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        teacherId,
        dayOfWeek,
        startTime,
        endTime,
        isAvailable,
        timezone,
        createdAt,
        updatedAt,
      ];
}
