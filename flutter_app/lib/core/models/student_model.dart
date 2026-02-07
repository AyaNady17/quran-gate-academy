import 'package:equatable/equatable.dart';

/// Student model
class StudentModel extends Equatable {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? whatsapp;
  final String? country;
  final String? countryCode;
  final String? timezone;
  final String? profilePicture;
  final String status; // 'active', 'inactive', 'graduated'
  final String? notes;
  final String? userId; // Links Student to User record when account is created
  final DateTime createdAt;
  final DateTime? updatedAt;

  const StudentModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.whatsapp,
    this.country,
    this.countryCode,
    this.timezone,
    this.profilePicture,
    this.status = 'active',
    this.notes,
    this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['\$id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'],
      phone: json['phone'],
      whatsapp: json['whatsapp'],
      country: json['country'],
      countryCode: json['countryCode'],
      timezone: json['timezone'],
      profilePicture: json['profilePicture'],
      status: json['status'] ?? 'active',
      notes: json['notes'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'whatsapp': whatsapp,
      'country': country,
      'countryCode': countryCode,
      'timezone': timezone,
      'profilePicture': profilePicture,
      'status': status,
      'notes': notes,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  StudentModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? whatsapp,
    String? country,
    String? countryCode,
    String? timezone,
    String? profilePicture,
    String? status,
    String? notes,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      timezone: timezone ?? this.timezone,
      profilePicture: profilePicture ?? this.profilePicture,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        whatsapp,
        country,
        countryCode,
        timezone,
        profilePicture,
        status,
        notes,
        userId,
        createdAt,
        updatedAt,
      ];
}
