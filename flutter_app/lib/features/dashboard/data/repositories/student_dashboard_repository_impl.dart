import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/features/dashboard/data/services/student_dashboard_service.dart';
import 'package:quran_gate_academy/features/dashboard/domain/repositories/student_dashboard_repository.dart';

/// Student Dashboard repository implementation
class StudentDashboardRepositoryImpl implements StudentDashboardRepository {
  final StudentDashboardService studentDashboardService;

  StudentDashboardRepositoryImpl({required this.studentDashboardService});

  @override
  Future<StudentDashboardStats> getDashboardStats({
    required String studentId,
  }) async {
    try {
      // Fetch all sessions, completed sessions, upcoming sessions, and today's sessions
      final allSessionsData =
          await studentDashboardService.getStudentSessions(studentId: studentId);
      final completedSessionsData =
          await studentDashboardService.getCompletedSessions(studentId: studentId);
      final upcomingSessionsData =
          await studentDashboardService.getUpcomingSessions(studentId: studentId);
      final todaySessionsData =
          await studentDashboardService.getTodaySessions(studentId: studentId);

      // Convert to models
      final completedSessions = completedSessionsData
          .map((data) => ClassSessionModel.fromJson(data))
          .toList();

      // Calculate total hours learned (only from completed sessions)
      final totalMinutes = completedSessions.fold<int>(
        0,
        (sum, session) => sum + session.duration,
      );
      final totalHours = totalMinutes / 60.0;

      // Calculate attendance percentage
      final totalSessions = allSessionsData.length;
      final completedCount = completedSessions.length;
      final attendancePercentage =
          totalSessions > 0 ? (completedCount / totalSessions) * 100 : 0.0;

      return StudentDashboardStats(
        totalSessions: totalSessions,
        completedSessions: completedCount,
        upcomingSessions: upcomingSessionsData.length,
        todaySessionsCount: todaySessionsData.length,
        totalHoursLearned: totalHours,
        attendancePercentage: attendancePercentage,
      );
    } catch (e) {
      throw Exception('Failed to get student dashboard stats: $e');
    }
  }

  @override
  Future<List<ClassSessionModel>> getTodaySessions({
    required String studentId,
  }) async {
    try {
      final sessionsData =
          await studentDashboardService.getTodaySessions(studentId: studentId);
      return sessionsData
          .map((data) => ClassSessionModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to get today\'s sessions: $e');
    }
  }

  @override
  Future<List<ClassSessionModel>> getUpcomingSessions({
    required String studentId,
  }) async {
    try {
      final sessionsData =
          await studentDashboardService.getUpcomingSessions(studentId: studentId);
      return sessionsData
          .map((data) => ClassSessionModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to get upcoming sessions: $e');
    }
  }

  @override
  Future<List<ClassSessionModel>> getCompletedSessions({
    required String studentId,
  }) async {
    try {
      final sessionsData =
          await studentDashboardService.getCompletedSessions(studentId: studentId);
      return sessionsData
          .map((data) => ClassSessionModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to get completed sessions: $e');
    }
  }

  @override
  Future<List<ClassSessionModel>> getAllSessions({
    required String studentId,
  }) async {
    try {
      final sessionsData =
          await studentDashboardService.getStudentSessions(studentId: studentId);
      return sessionsData
          .map((data) => ClassSessionModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all sessions: $e');
    }
  }

  @override
  Future<List<ClassSessionModel>> getSessionsByDateRange({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final sessionsData = await studentDashboardService.getSessionsByDateRange(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );
      return sessionsData
          .map((data) => ClassSessionModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sessions by date range: $e');
    }
  }
}
