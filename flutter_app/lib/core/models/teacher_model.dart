import 'package:equatable/equatable.dart';

/// Teacher model representing a teacher in the system
class TeacherModel extends Equatable {
  final String id;
  final String userId; // Reference to Appwrite auth user
  final String fullName;
  final String email;
  final String phone;
  final double hourlyRate;
  final String? specialization;
  final String status; // 'active', 'inactive'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TeacherModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.hourlyRate,
    this.specialization,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create TeacherModel from JSON
  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['\$id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      specialization: json['specialization'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert TeacherModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '\$id': id,
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'hourlyRate': hourlyRate,
      'specialization': specialization,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  TeacherModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? phone,
    double? hourlyRate,
    String? specialization,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      specialization: specialization ?? this.specialization,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        fullName,
        email,
        phone,
        hourlyRate,
        specialization,
        status,
        createdAt,
        updatedAt,
      ];
}
