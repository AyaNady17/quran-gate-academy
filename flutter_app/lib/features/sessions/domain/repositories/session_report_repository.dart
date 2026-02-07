import 'package:quran_gate_academy/core/models/session_report_model.dart';

/// Repository interface for session reports
abstract class SessionReportRepository {
  Future<SessionReportModel> createReport({
    required String sessionId,
    required String studentId,
    required String teacherId,
    required String attendance,
    String? performance,
    String? summary,
    String? homework,
    String? encouragementMessage,
    DateTime? sessionEnteredAt,
    DateTime? sessionEndedAt,
    required bool teacherLate,
    required int lateDurationMinutes,
  });

  Future<List<SessionReportModel>> getReportsByStudent(String studentId);
  Future<List<SessionReportModel>> getReportsByTeacher(String teacherId);
  Future<SessionReportModel?> getReportBySession(String sessionId);
  Future<List<SessionReportModel>> getAllReports();
  Future<List<SessionReportModel>> getLateTeacherReports();

  Future<SessionReportModel> updateReport({
    required String reportId,
    String? attendance,
    String? performance,
    String? summary,
    String? homework,
    String? encouragementMessage,
  });

  Future<void> deleteReport(String reportId);
}
