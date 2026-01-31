import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/features/dashboard/data/services/dashboard_service.dart';
import 'package:quran_gate_academy/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Dashboard repository implementation
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardService dashboardService;

  DashboardRepositoryImpl({required this.dashboardService});

  @override
  Future<DashboardStats> getDashboardStats({required String teacherId}) async {
    try {
      // Fetch all sessions and completed sessions
      final allSessionsData = await dashboardService.getTeacherSessions(teacherId: teacherId);
      final completedSessionsData = await dashboardService.getCompletedSessions(teacherId: teacherId);
      final todaySessionsData = await dashboardService.getTodaySessions(teacherId: teacherId);

      // Convert to models
      final allSessions = allSessionsData.map((data) => ClassSessionModel.fromJson(data)).toList();
      final completedSessions = completedSessionsData.map((data) => ClassSessionModel.fromJson(data)).toList();

      // Calculate total hours
      final totalMinutes = completedSessions.fold<int>(
        0,
        (sum, session) => sum + session.duration,
      );
      final totalHours = totalMinutes / 60.0;

      // Calculate total salary
      final totalSalary = completedSessions.fold<double>(
        0.0,
        (sum, session) => sum + session.salaryAmount,
      );

      // Calculate attendance percentage
      final totalSessions = allSessions.length;
      final completedCount = completedSessions.length;
      final attendancePercentage = totalSessions > 0
          ? (completedCount / totalSessions) * 100
          : 0.0;

      return DashboardStats(
        totalHours: totalHours,
        totalSalary: totalSalary,
        attendancePercentage: attendancePercentage,
        totalSessions: totalSessions,
        completedSessions: completedCount,
        todaySessionsCount: todaySessionsData.length,
      );
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  @override
  Future<List<ClassSessionModel>> getTodaySessions({required String teacherId}) async {
    try {
      final sessionsData = await dashboardService.getTodaySessions(teacherId: teacherId);
      return sessionsData.map((data) => ClassSessionModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get today\'s sessions: $e');
    }
  }

  @override
  Future<List<ClassSessionModel>> getWeeklySessions({required String teacherId}) async {
    try {
      final sessionsData = await dashboardService.getWeeklySessions(teacherId: teacherId);
      return sessionsData.map((data) => ClassSessionModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get weekly sessions: $e');
    }
  }

  @override
  Future<List<ClassSessionModel>> getMonthlySessions({required String teacherId}) async {
    try {
      final sessionsData = await dashboardService.getMonthlySessions(teacherId: teacherId);
      return sessionsData.map((data) => ClassSessionModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get monthly sessions: $e');
    }
  }

  @override
  Future<List<ClassSessionModel>> getAllSessions() async {
    try {
      final sessionsData = await dashboardService.getAllSessions(
        isAdminRequest: true,
      );
      return sessionsData.map((data) => ClassSessionModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get all sessions: $e');
    }
  }
}
