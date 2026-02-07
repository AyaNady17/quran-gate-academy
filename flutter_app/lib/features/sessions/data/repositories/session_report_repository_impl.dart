import 'package:quran_gate_academy/core/models/session_report_model.dart';
import 'package:quran_gate_academy/features/sessions/data/services/session_report_service.dart';
import 'package:quran_gate_academy/features/sessions/domain/repositories/session_report_repository.dart';

/// Implementation of SessionReportRepository
class SessionReportRepositoryImpl implements SessionReportRepository {
  final SessionReportService sessionReportService;

  SessionReportRepositoryImpl({required this.sessionReportService});

  @override
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
  }) async {
    try {
      final data = await sessionReportService.createReport(
        sessionId: sessionId,
        studentId: studentId,
        teacherId: teacherId,
        attendance: attendance,
        performance: performance,
        summary: summary,
        homework: homework,
        encouragementMessage: encouragementMessage,
        sessionEnteredAt: sessionEnteredAt,
        sessionEndedAt: sessionEndedAt,
        teacherLate: teacherLate,
        lateDurationMinutes: lateDurationMinutes,
      );
      return SessionReportModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  @override
  Future<List<SessionReportModel>> getReportsByStudent(String studentId) async {
    try {
      final dataList = await sessionReportService.getReportsByStudent(studentId);
      return dataList.map((data) => SessionReportModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get student reports: $e');
    }
  }

  @override
  Future<List<SessionReportModel>> getReportsByTeacher(String teacherId) async {
    try {
      final dataList = await sessionReportService.getReportsByTeacher(teacherId);
      return dataList.map((data) => SessionReportModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get teacher reports: $e');
    }
  }

  @override
  Future<SessionReportModel?> getReportBySession(String sessionId) async {
    try {
      final data = await sessionReportService.getReportBySession(sessionId);
      if (data == null) return null;
      return SessionReportModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get session report: $e');
    }
  }

  @override
  Future<List<SessionReportModel>> getAllReports() async {
    try {
      final dataList = await sessionReportService.getAllReports();
      return dataList.map((data) => SessionReportModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get all reports: $e');
    }
  }

  @override
  Future<List<SessionReportModel>> getLateTeacherReports() async {
    try {
      final dataList = await sessionReportService.getLateTeacherReports();
      return dataList.map((data) => SessionReportModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get late teacher reports: $e');
    }
  }

  @override
  Future<SessionReportModel> updateReport({
    required String reportId,
    String? attendance,
    String? performance,
    String? summary,
    String? homework,
    String? encouragementMessage,
  }) async {
    try {
      final data = await sessionReportService.updateReport(
        reportId: reportId,
        attendance: attendance,
        performance: performance,
        summary: summary,
        homework: homework,
        encouragementMessage: encouragementMessage,
      );
      return SessionReportModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      await sessionReportService.deleteReport(reportId);
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }
}
