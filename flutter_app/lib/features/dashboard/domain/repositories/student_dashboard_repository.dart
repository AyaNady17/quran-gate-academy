import 'package:quran_gate_academy/core/models/class_session_model.dart';

/// Student Dashboard statistics model
class StudentDashboardStats {
  final int totalSessions;
  final int completedSessions;
  final int upcomingSessions;
  final int todaySessionsCount;
  final double totalHoursLearned;
  final double attendancePercentage;

  const StudentDashboardStats({
    required this.totalSessions,
    required this.completedSessions,
    required this.upcomingSessions,
    required this.todaySessionsCount,
    required this.totalHoursLearned,
    required this.attendancePercentage,
  });
}

/// Student Dashboard repository interface
abstract class StudentDashboardRepository {
  /// Get dashboard statistics for a student
  Future<StudentDashboardStats> getDashboardStats({required String studentId});

  /// Get today's sessions for a student
  Future<List<ClassSessionModel>> getTodaySessions({required String studentId});

  /// Get upcoming sessions for a student
  Future<List<ClassSessionModel>> getUpcomingSessions({required String studentId});

  /// Get completed sessions for a student
  Future<List<ClassSessionModel>> getCompletedSessions({required String studentId});

  /// Get all sessions for a student
  Future<List<ClassSessionModel>> getAllSessions({required String studentId});

  /// Get sessions for a student in a specific date range
  Future<List<ClassSessionModel>> getSessionsByDateRange({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
