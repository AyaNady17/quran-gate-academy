import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/features/dashboard/data/services/student_dashboard_service.dart';
import 'package:quran_gate_academy/features/dashboard/domain/repositories/student_dashboard_repository.dart';

/// Implementation of StudentDashboardRepository
class StudentDashboardRepositoryImpl implements StudentDashboardRepository {
  final StudentDashboardService studentDashboardService;

  StudentDashboardRepositoryImpl({
    required this.studentDashboardService,
  });

  @override
  Future<StudentDashboardStats> getDashboardStats({
    required String studentId,
  }) async {
    try {
      // Fetch all sessions to calculate stats
      final allSessions = await getAllSessions(studentId: studentId);

      final completedSessions = allSessions
          .where((s) => s.status == 'completed')
          .toList();

      final now = DateTime.now();
      final upcomingSessions = allSessions
          .where((s) =>
              s.status == 'scheduled' &&
              s.scheduledDate.isAfter(now))
          .toList();

      final todaySessions = await getTodaySessions(studentId: studentId);

      // Calculate total hours learned (completed sessions only)
      final totalHoursLearned = completedSessions.fold<double>(
        0.0,
        (sum, session) => sum + (session.duration / 60),
      );

      // Calculate attendance percentage
      final attendancePercentage = allSessions.isNotEmpty
          ? (completedSessions.length / allSessions.length) * 100
          : 0.0;

      return StudentDashboardStats(
        totalSessions: allSessions.length,
        completedSessions: completedSessions.length,
        upcomingSessions: upcomingSessions.length,
        todaySessionsCount: todaySessions.length,
        totalHoursLearned: totalHoursLearned,
        attendancePercentage: attendancePercentage,
      );
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  @override
  Future<List<ClassSessionModel>> getTodaySessions({
    required String studentId,
  }) async {
    try {
      final sessionsData = await studentDashboardService.getTodaySessions(
        studentId: studentId,
      );
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
      final sessionsData = await studentDashboardService.getUpcomingSessions(
        studentId: studentId,
      );
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
      final sessionsData = await studentDashboardService.getCompletedSessions(
        studentId: studentId,
      );
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
      final sessionsData = await studentDashboardService.getStudentSessions(
        studentId: studentId,
      );
      return sessionsData
          .map((data) => ClassSessionModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all sessions: $e');
    }
  }
}
