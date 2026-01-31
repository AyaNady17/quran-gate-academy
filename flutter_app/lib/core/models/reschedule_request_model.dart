import 'package:equatable/equatable.dart';

/// Reschedule request model
class RescheduleRequestModel extends Equatable {
  final String id;
  final String sessionId;
  final String requestedBy;
  final String requestedByRole; // 'teacher' or 'admin'
  final DateTime originalDate;
  final String originalTime;
  final DateTime newDate;
  final String newTime;
  final String? reason;
  final String status; // 'pending', 'approved', 'rejected'
  final String? reviewedBy;
  final String? reviewNotes;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RescheduleRequestModel({
    required this.id,
    required this.sessionId,
    required this.requestedBy,
    required this.requestedByRole,
    required this.originalDate,
    required this.originalTime,
    required this.newDate,
    required this.newTime,
    this.reason,
    this.status = 'pending',
    this.reviewedBy,
    this.reviewNotes,
    this.reviewedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory RescheduleRequestModel.fromJson(Map<String, dynamic> json) {
    return RescheduleRequestModel(
      id: json['\$id'] ?? '',
      sessionId: json['sessionId'] ?? '',
      requestedBy: json['requestedBy'] ?? '',
      requestedByRole: json['requestedByRole'] ?? 'teacher',
      originalDate: DateTime.parse(json['originalDate']),
      originalTime: json['originalTime'] ?? '',
      newDate: DateTime.parse(json['newDate']),
      newTime: json['newTime'] ?? '',
      reason: json['reason'],
      status: json['status'] ?? 'pending',
      reviewedBy: json['reviewedBy'],
      reviewNotes: json['reviewNotes'],
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'requestedBy': requestedBy,
      'requestedByRole': requestedByRole,
      'originalDate': originalDate.toIso8601String(),
      'originalTime': originalTime,
      'newDate': newDate.toIso8601String(),
      'newTime': newTime,
      'reason': reason,
      'status': status,
      'reviewedBy': reviewedBy,
      'reviewNotes': reviewNotes,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  RescheduleRequestModel copyWith({
    String? id,
    String? sessionId,
    String? requestedBy,
    String? requestedByRole,
    DateTime? originalDate,
    String? originalTime,
    DateTime? newDate,
    String? newTime,
    String? reason,
    String? status,
    String? reviewedBy,
    String? reviewNotes,
    DateTime? reviewedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RescheduleRequestModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      requestedBy: requestedBy ?? this.requestedBy,
      requestedByRole: requestedByRole ?? this.requestedByRole,
      originalDate: originalDate ?? this.originalDate,
      originalTime: originalTime ?? this.originalTime,
      newDate: newDate ?? this.newDate,
      newTime: newTime ?? this.newTime,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        requestedBy,
        requestedByRole,
        originalDate,
        originalTime,
        newDate,
        newTime,
        reason,
        status,
        reviewedBy,
        reviewNotes,
        reviewedAt,
        createdAt,
        updatedAt,
      ];
}
