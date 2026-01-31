import 'package:equatable/equatable.dart';

/// User model for teachers and admins
class UserModel extends Equatable {
  final String id;
  final String userId;
  final String email;
  final String fullName;
  final String role; // 'admin' or 'teacher'
  final String? phone;
  final double hourlyRate;
  final String? profilePicture;
  final String status; // 'active', 'inactive', 'suspended'
  final String? specialization;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.hourlyRate = 0,
    this.profilePicture,
    this.status = 'active',
    this.specialization,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['\$id'] ?? '',
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'teacher',
      phone: json['phone'],
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      profilePicture: json['profilePicture'],
      status: json['status'] ?? 'active',
      specialization: json['specialization'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'role': role,
      'phone': phone,
      'hourlyRate': hourlyRate,
      'profilePicture': profilePicture,
      'status': status,
      'specialization': specialization,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? userId,
    String? email,
    String? fullName,
    String? role,
    String? phone,
    double? hourlyRate,
    String? profilePicture,
    String? status,
    String? specialization,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      profilePicture: profilePicture ?? this.profilePicture,
      status: status ?? this.status,
      specialization: specialization ?? this.specialization,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        email,
        fullName,
        role,
        phone,
        hourlyRate,
        profilePicture,
        status,
        specialization,
        createdAt,
        updatedAt,
      ];
}
