import 'package:equatable/equatable.dart';

/// Class session model
class ClassSessionModel extends Equatable {
  final String id;
  final String teacherId;
  final String studentId;
  final String courseId;
  final String? planId;
  final DateTime scheduledDate;
  final String scheduledTime; // e.g., "19:00"
  final int duration; // minutes
  final String status; // 'scheduled', 'completed', 'absent', 'student_cancel', 'teacher_cancel'
  final String? attendanceStatus; // 'present', 'absent', 'late'
  final double salaryAmount;
  final String? notes;
  final String? meetingLink;
  final String? createdBy;
  final String? rescheduleRequestId;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ClassSessionModel({
    required this.id,
    required this.teacherId,
    required this.studentId,
    required this.courseId,
    this.planId,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.duration,
    this.status = 'scheduled',
    this.attendanceStatus,
    this.salaryAmount = 0,
    this.notes,
    this.meetingLink,
    this.createdBy,
    this.rescheduleRequestId,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory ClassSessionModel.fromJson(Map<String, dynamic> json) {
    return ClassSessionModel(
      id: json['\$id'] ?? '',
      teacherId: json['teacherId'] ?? '',
      studentId: json['studentId'] ?? '',
      courseId: json['courseId'] ?? '',
      planId: json['planId'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      scheduledTime: json['scheduledTime'] ?? '',
      duration: json['duration'] ?? 60,
      status: json['status'] ?? 'scheduled',
      attendanceStatus: json['attendanceStatus'],
      salaryAmount: (json['salaryAmount'] ?? 0).toDouble(),
      notes: json['notes'],
      meetingLink: json['meetingLink'],
      createdBy: json['createdBy'],
      rescheduleRequestId: json['rescheduleRequestId'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'studentId': studentId,
      'courseId': courseId,
      'planId': planId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': scheduledTime,
      'duration': duration,
      'status': status,
      'attendanceStatus': attendanceStatus,
      'salaryAmount': salaryAmount,
      'notes': notes,
      'meetingLink': meetingLink,
      'createdBy': createdBy,
      'rescheduleRequestId': rescheduleRequestId,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ClassSessionModel copyWith({
    String? id,
    String? teacherId,
    String? studentId,
    String? courseId,
    String? planId,
    DateTime? scheduledDate,
    String? scheduledTime,
    int? duration,
    String? status,
    String? attendanceStatus,
    double? salaryAmount,
    String? notes,
    String? meetingLink,
    String? createdBy,
    String? rescheduleRequestId,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassSessionModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      planId: planId ?? this.planId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      salaryAmount: salaryAmount ?? this.salaryAmount,
      notes: notes ?? this.notes,
      meetingLink: meetingLink ?? this.meetingLink,
      createdBy: createdBy ?? this.createdBy,
      rescheduleRequestId: rescheduleRequestId ?? this.rescheduleRequestId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        teacherId,
        studentId,
        courseId,
        planId,
        scheduledDate,
        scheduledTime,
        duration,
        status,
        attendanceStatus,
        salaryAmount,
        notes,
        meetingLink,
        createdBy,
        rescheduleRequestId,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
