import 'package:equatable/equatable.dart';

/// Plan model
class PlanModel extends Equatable {
  final String id;
  final String studentId;
  final String courseId;
  final String planName;
  final int totalSessions;
  final int completedSessions;
  final int remainingSessions;
  final int sessionDuration; // minutes
  final double totalPrice;
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PlanModel({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.planName,
    required this.totalSessions,
    this.completedSessions = 0,
    required this.remainingSessions,
    required this.sessionDuration,
    this.totalPrice = 0,
    this.status = 'active',
    this.startDate,
    this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['\$id'] ?? '',
      studentId: json['studentId'] ?? '',
      courseId: json['courseId'] ?? '',
      planName: json['planName'] ?? '',
      totalSessions: json['totalSessions'] ?? 0,
      completedSessions: json['completedSessions'] ?? 0,
      remainingSessions: json['remainingSessions'] ?? 0,
      sessionDuration: json['sessionDuration'] ?? 60,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'active',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'planName': planName,
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'remainingSessions': remainingSessions,
      'sessionDuration': sessionDuration,
      'totalPrice': totalPrice,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  PlanModel copyWith({
    String? id,
    String? studentId,
    String? courseId,
    String? planName,
    int? totalSessions,
    int? completedSessions,
    int? remainingSessions,
    int? sessionDuration,
    double? totalPrice,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlanModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      planName: planName ?? this.planName,
      totalSessions: totalSessions ?? this.totalSessions,
      completedSessions: completedSessions ?? this.completedSessions,
      remainingSessions: remainingSessions ?? this.remainingSessions,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        courseId,
        planName,
        totalSessions,
        completedSessions,
        remainingSessions,
        sessionDuration,
        totalPrice,
        status,
        startDate,
        endDate,
        createdAt,
        updatedAt,
      ];
}
