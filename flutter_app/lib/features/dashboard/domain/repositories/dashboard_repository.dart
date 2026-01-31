import 'package:quran_gate_academy/core/models/class_session_model.dart';

/// Dashboard statistics model
class DashboardStats {
  final double totalHours;
  final double totalSalary;
  final double attendancePercentage;
  final int totalSessions;
  final int completedSessions;
  final int todaySessionsCount;

  const DashboardStats({
    required this.totalHours,
    required this.totalSalary,
    required this.attendancePercentage,
    required this.totalSessions,
    required this.completedSessions,
    required this.todaySessionsCount,
  });
}

/// Dashboard repository interface
abstract class DashboardRepository {
  /// Get dashboard statistics for a teacher
  Future<DashboardStats> getDashboardStats({required String teacherId});

  /// Get today's sessions for a teacher
  Future<List<ClassSessionModel>> getTodaySessions({required String teacherId});

  /// Get weekly sessions for a teacher
  Future<List<ClassSessionModel>> getWeeklySessions({required String teacherId});

  /// Get monthly sessions for a teacher
  Future<List<ClassSessionModel>> getMonthlySessions({required String teacherId});

  /// Get all sessions (for admin)
  Future<List<ClassSessionModel>> getAllSessions();
}
