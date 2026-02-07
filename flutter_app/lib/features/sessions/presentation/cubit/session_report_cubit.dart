import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/features/sessions/domain/repositories/session_report_repository.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_report_state.dart';

/// Cubit for managing session reports
class SessionReportCubit extends Cubit<SessionReportState> {
  final SessionReportRepository sessionReportRepository;

  SessionReportCubit({required this.sessionReportRepository})
      : super(SessionReportInitial());

  /// Create a new session report
  Future<void> createReport({
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
    emit(SessionReportLoading());

    try {
      final report = await sessionReportRepository.createReport(
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

      emit(SessionReportCreated(report));
    } catch (e) {
      emit(SessionReportError(e.toString()));
    }
  }

  /// Load reports by student
  Future<void> loadReportsByStudent(String studentId) async {
    emit(SessionReportLoading());

    try {
      final reports = await sessionReportRepository.getReportsByStudent(studentId);
      emit(SessionReportsLoaded(reports));
    } catch (e) {
      emit(SessionReportError(e.toString()));
    }
  }

  /// Load reports by teacher
  Future<void> loadReportsByTeacher(String teacherId) async {
    emit(SessionReportLoading());

    try {
      final reports = await sessionReportRepository.getReportsByTeacher(teacherId);
      emit(SessionReportsLoaded(reports));
    } catch (e) {
      emit(SessionReportError(e.toString()));
    }
  }

  /// Load report by session
  Future<void> loadReportBySession(String sessionId) async {
    emit(SessionReportLoading());

    try {
      final report = await sessionReportRepository.getReportBySession(sessionId);
      emit(SessionReportLoaded(report));
    } catch (e) {
      emit(SessionReportError(e.toString()));
    }
  }

  /// Load all reports (admin)
  Future<void> loadAllReports() async {
    emit(SessionReportLoading());

    try {
      final reports = await sessionReportRepository.getAllReports();
      emit(SessionReportsLoaded(reports));
    } catch (e) {
      emit(SessionReportError(e.toString()));
    }
  }

  /// Load late teacher reports (admin)
  Future<void> loadLateTeacherReports() async {
    emit(SessionReportLoading());

    try {
      final reports = await sessionReportRepository.getLateTeacherReports();
      emit(SessionReportsLoaded(reports));
    } catch (e) {
      emit(SessionReportError(e.toString()));
    }
  }

  /// Update a report
  Future<void> updateReport({
    required String reportId,
    String? attendance,
    String? performance,
    String? summary,
    String? homework,
    String? encouragementMessage,
  }) async {
    emit(SessionReportLoading());

    try {
      final report = await sessionReportRepository.updateReport(
        reportId: reportId,
        attendance: attendance,
        performance: performance,
        summary: summary,
        homework: homework,
        encouragementMessage: encouragementMessage,
      );

      emit(SessionReportUpdated(report));
    } catch (e) {
      emit(SessionReportError(e.toString()));
    }
  }

  /// Delete a report (admin only)
  Future<void> deleteReport(String reportId) async {
    emit(SessionReportLoading());

    try {
      await sessionReportRepository.deleteReport(reportId);
      emit(SessionReportDeleted());
    } catch (e) {
      emit(SessionReportError(e.toString()));
    }
  }
}
