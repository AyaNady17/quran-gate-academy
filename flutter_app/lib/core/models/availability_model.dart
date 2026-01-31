import 'package:equatable/equatable.dart';

/// Availability model representing a teacher's availability time slot
class AvailabilityModel extends Equatable {
  final String id;
  final String teacherId;
  final String dayOfWeek; // Monday, Tuesday, Wednesday, etc.
  final String startTime; // HH:mm format (e.g., "09:00")
  final String endTime; // HH:mm format (e.g., "11:00")
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AvailabilityModel({
    required this.id,
    required this.teacherId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create AvailabilityModel from JSON
  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['\$id'] as String,
      teacherId: json['teacherId'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert AvailabilityModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '\$id': id,
      'teacherId': teacherId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  AvailabilityModel copyWith({
    String? id,
    String? teacherId,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AvailabilityModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
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
        createdAt,
        updatedAt,
      ];
}
