import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/core/utils/name_cache.dart';
import 'package:quran_gate_academy/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/teacher_dashboard_state.dart';
import 'package:quran_gate_academy/features/students/domain/repositories/student_repository.dart';

/// Teacher Dashboard Cubit - Manages teacher dashboard state
class TeacherDashboardCubit extends Cubit<TeacherDashboardState> {
  final DashboardRepository dashboardRepository;
  final StudentRepository studentRepository;

  TeacherDashboardCubit({
    required this.dashboardRepository,
    required this.studentRepository,
  }) : super(TeacherDashboardInitial());

  /// Load teacher dashboard with personal statistics
  Future<void> loadDashboard({required String teacherId}) async {
    emit(TeacherDashboardLoading());
    try {
      // Fetch teacher-specific data (filtered by teacherId)
      final monthlySessions = await dashboardRepository.getMonthlySessions(
        teacherId: teacherId,
      );

      final todaySessions = await dashboardRepository.getTodaySessions(
        teacherId: teacherId,
      );

      // Get upcoming sessions (scheduled sessions from today onwards)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final upcomingSessions = monthlySessions
          .where((session) =>
              session.status == 'scheduled' &&
              session.scheduledDate.isAfter(today))
          .toList();

      // Calculate statistics
      final stats = _calculateStats(
        monthlySessions,
        todaySessions,
        upcomingSessions,
      );

      // Fetch student names if missing
      final allDashboardSessions = [...todaySessions, ...upcomingSessions];
      final missingStudentIds = allDashboardSessions
          .map((s) => s.studentId)
          .where((id) => !NameCache.hasStudent(id))
          .toSet();

      if (missingStudentIds.isNotEmpty) {
        final allStudents = await studentRepository.getAllStudents();
        for (var s in allStudents) {
          NameCache.cacheStudentName(s.id, s.fullName);
        }
      }

      // Populate names
      final populatedTodaySessions = todaySessions.map((session) {
        return session.copyWith(
          studentName:
              NameCache.getStudentName(session.studentId) ?? 'Unknown Student',
        );
      }).toList();

      final populatedUpcomingSessions = upcomingSessions.map((session) {
        return session.copyWith(
          studentName:
              NameCache.getStudentName(session.studentId) ?? 'Unknown Student',
        );
      }).toList();

      emit(TeacherDashboardLoaded(
        stats: stats,
        todaySessions: populatedTodaySessions,
        upcomingSessions: populatedUpcomingSessions,
      ));
    } catch (e) {
      emit(TeacherDashboardError(
          'Failed to load teacher dashboard: ${e.toString()}'));
    }
  }

  /// Refresh dashboard
  Future<void> refreshDashboard({required String teacherId}) async {
    await loadDashboard(teacherId: teacherId);
  }

  /// Calculate teacher statistics from sessions
  TeacherDashboardStats _calculateStats(
    List<ClassSessionModel> monthlySessions,
    List<ClassSessionModel> todaySessions,
    List<ClassSessionModel> upcomingSessions,
  ) {
    // Filter completed sessions from monthly data
    final completedSessions = monthlySessions
        .where((session) => session.status == 'completed')
        .toList();

    // Calculate monthly hours (duration in minutes / 60)
    final monthlyHours = completedSessions.fold<double>(
      0,
      (sum, session) => sum + (session.duration / 60),
    );

    // Calculate monthly salary
    final monthlySalary = completedSessions.fold<double>(
      0,
      (sum, session) => sum + session.salaryAmount,
    );

    // Calculate attendance percentage (based on monthly sessions)
    final totalSessionsCount = monthlySessions.length;
    final completedSessionsCount = completedSessions.length;
    final attendancePercentage = totalSessionsCount > 0
        ? (completedSessionsCount / totalSessionsCount) * 100
        : 0.0;

    return TeacherDashboardStats(
      totalHours: monthlyHours, // For now, showing monthly stats
      totalSalary: monthlySalary, // For now, showing monthly stats
      attendancePercentage: attendancePercentage,
      totalSessions: totalSessionsCount,
      completedSessions: completedSessionsCount,
      todaySessionsCount: todaySessions.length,
      upcomingSessionsCount: upcomingSessions.length,
      monthlyHours: monthlyHours,
      monthlySalary: monthlySalary,
    );
  }
}
