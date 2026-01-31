import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/core/models/student_model.dart';
import 'package:quran_gate_academy/core/models/teacher_model.dart';
import 'package:quran_gate_academy/core/utils/name_cache.dart';
import 'package:quran_gate_academy/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/admin_dashboard_state.dart';
import 'package:quran_gate_academy/features/students/domain/repositories/student_repository.dart';
import 'package:quran_gate_academy/features/teachers/domain/repositories/teacher_repository.dart';

/// Admin Dashboard Cubit - Manages admin dashboard state
class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final DashboardRepository dashboardRepository;
  final TeacherRepository teacherRepository;
  final StudentRepository studentRepository;

  AdminDashboardCubit({
    required this.dashboardRepository,
    required this.teacherRepository,
    required this.studentRepository,
  }) : super(AdminDashboardInitial());

  /// Load admin dashboard with system-wide statistics
  Future<void> loadDashboard() async {
    emit(AdminDashboardLoading());
    try {
      // Fetch system-wide data (no teacherId filter for admin)
      final allSessions = await dashboardRepository.getAllSessions();
      var recentSessions = allSessions.take(10).toList();

      // Fetch names if missing
      final missingTeacherIds = recentSessions
          .map((s) => s.teacherId)
          .where((id) => !NameCache.hasTeacher(id))
          .toSet();
      final missingStudentIds = recentSessions
          .map((s) => s.studentId)
          .where((id) => !NameCache.hasStudent(id))
          .toSet();

      if (missingTeacherIds.isNotEmpty || missingStudentIds.isNotEmpty) {
        final results = await Future.wait([
          teacherRepository.getAllTeachers(),
          studentRepository.getAllStudents(),
        ]);

        final allTeachers = results[0] as List<TeacherModel>;
        final allStudents = results[1] as List<StudentModel>;

        for (var t in allTeachers) {
          NameCache.cacheTeacherName(t.id, t.fullName);
        }
        for (var s in allStudents) {
          NameCache.cacheStudentName(s.id, s.fullName);
        }
      }

      // Populate names
      recentSessions = recentSessions.map((session) {
        return session.copyWith(
          teacherName:
              NameCache.getTeacherName(session.teacherId) ?? 'Unknown Teacher',
          studentName:
              NameCache.getStudentName(session.studentId) ?? 'Unknown Student',
        );
      }).toList();

      // Calculate statistics
      final stats = _calculateStats(allSessions);

      emit(AdminDashboardLoaded(
        stats: stats,
        recentSessions: recentSessions,
      ));
    } catch (e) {
      emit(AdminDashboardError(
          'Failed to load admin dashboard: ${e.toString()}'));
    }
  }

  /// Refresh dashboard
  Future<void> refreshDashboard() async {
    await loadDashboard();
  }

  /// Calculate admin statistics from sessions
  AdminDashboardStats _calculateStats(List<ClassSessionModel> sessions) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // Filter completed sessions
    final completedSessions =
        sessions.where((session) => session.status == 'completed').toList();

    // Filter scheduled sessions
    final scheduledSessions =
        sessions.where((session) => session.status == 'scheduled').toList();

    // Filter sessions for current month
    final monthlySessions = sessions.where((session) {
      return session.scheduledDate.isAfter(monthStart) &&
          session.scheduledDate.isBefore(monthEnd);
    }).toList();

    final monthlyCompletedSessions = monthlySessions
        .where((session) => session.status == 'completed')
        .toList();

    // Calculate revenue
    final totalRevenue = completedSessions.fold<double>(
      0,
      (sum, session) => sum + session.salaryAmount,
    );

    final monthlyRevenue = monthlyCompletedSessions.fold<double>(
      0,
      (sum, session) => sum + session.salaryAmount,
    );

    // Get unique teachers and students
    final uniqueTeachers = sessions.map((s) => s.teacherId).toSet();
    final uniqueStudents = sessions.map((s) => s.studentId).toSet();

    // TODO: Fetch actual teacher/student counts from services
    // For now, use unique IDs from sessions as approximation
    final totalTeachers = uniqueTeachers.length;
    final totalStudents = uniqueStudents.length;

    return AdminDashboardStats(
      totalTeachers: totalTeachers,
      activeTeachers: totalTeachers, // TODO: Filter by status='active'
      totalStudents: totalStudents,
      activeStudents: totalStudents, // TODO: Filter by status='active'
      totalSessions: sessions.length,
      completedSessions: completedSessions.length,
      scheduledSessions: scheduledSessions.length,
      totalRevenue: totalRevenue,
      monthlyRevenue: monthlyRevenue,
    );
  }
}
