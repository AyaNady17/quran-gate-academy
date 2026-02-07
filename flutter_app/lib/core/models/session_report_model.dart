import 'package:equatable/equatable.dart';

/// Session Report Model - Represents a completed session report
class SessionReportModel extends Equatable {
  final String id;
  final String sessionId;
  final String studentId;
  final String teacherId;
  final String attendance; // 'attended' or 'absent'
  final String? performance; // 'good' or 'excellent' - required if attended
  final String? summary; // Session summary/title
  final String? homework; // Homework assignment
  final String? encouragementMessage; // Motivational message
  final DateTime? sessionEnteredAt; // When teacher entered the class
  final DateTime? sessionEndedAt; // When teacher ended the class
  final bool teacherLate; // Was teacher late
  final int lateDurationMinutes; // How many minutes late
  final DateTime createdAt;
  final DateTime updatedAt;

  const SessionReportModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.teacherId,
    required this.attendance,
    this.performance,
    this.summary,
    this.homework,
    this.encouragementMessage,
    this.sessionEnteredAt,
    this.sessionEndedAt,
    required this.teacherLate,
    required this.lateDurationMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON (Appwrite document)
  factory SessionReportModel.fromJson(Map<String, dynamic> json) {
    return SessionReportModel(
      id: json['\$id'] as String,
      sessionId: json['sessionId'] as String,
      studentId: json['studentId'] as String,
      teacherId: json['teacherId'] as String,
      attendance: json['attendance'] as String,
      performance: json['performance'] as String?,
      summary: json['summary'] as String?,
      homework: json['homework'] as String?,
      encouragementMessage: json['encouragementMessage'] as String?,
      sessionEnteredAt: json['sessionEnteredAt'] != null
          ? DateTime.parse(json['sessionEnteredAt'] as String)
          : null,
      sessionEndedAt: json['sessionEndedAt'] != null
          ? DateTime.parse(json['sessionEndedAt'] as String)
          : null,
      teacherLate: json['teacherLate'] as bool? ?? false,
      lateDurationMinutes: json['lateDurationMinutes'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON (for Appwrite)
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'studentId': studentId,
      'teacherId': teacherId,
      'attendance': attendance,
      if (performance != null) 'performance': performance,
      if (summary != null) 'summary': summary,
      if (homework != null) 'homework': homework,
      if (encouragementMessage != null) 'encouragementMessage': encouragementMessage,
      if (sessionEnteredAt != null) 'sessionEnteredAt': sessionEnteredAt!.toIso8601String(),
      if (sessionEndedAt != null) 'sessionEndedAt': sessionEndedAt!.toIso8601String(),
      'teacherLate': teacherLate,
      'lateDurationMinutes': lateDurationMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  SessionReportModel copyWith({
    String? id,
    String? sessionId,
    String? studentId,
    String? teacherId,
    String? attendance,
    String? performance,
    String? summary,
    String? homework,
    String? encouragementMessage,
    DateTime? sessionEnteredAt,
    DateTime? sessionEndedAt,
    bool? teacherLate,
    int? lateDurationMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionReportModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      attendance: attendance ?? this.attendance,
      performance: performance ?? this.performance,
      summary: summary ?? this.summary,
      homework: homework ?? this.homework,
      encouragementMessage: encouragementMessage ?? this.encouragementMessage,
      sessionEnteredAt: sessionEnteredAt ?? this.sessionEnteredAt,
      sessionEndedAt: sessionEndedAt ?? this.sessionEndedAt,
      teacherLate: teacherLate ?? this.teacherLate,
      lateDurationMinutes: lateDurationMinutes ?? this.lateDurationMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if student attended
  bool get isAttended => attendance == 'attended';

  /// Check if report is complete (all required fields filled)
  bool get isComplete {
    if (!isAttended) return true; // Absent reports are always complete
    return performance != null &&
        summary != null &&
        homework != null &&
        encouragementMessage != null;
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        studentId,
        teacherId,
        attendance,
        performance,
        summary,
        homework,
        encouragementMessage,
        sessionEnteredAt,
        sessionEndedAt,
        teacherLate,
        lateDurationMinutes,
        createdAt,
        updatedAt,
      ];
}
