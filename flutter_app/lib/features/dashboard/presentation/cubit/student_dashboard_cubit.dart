import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/core/utils/name_cache.dart';
import 'package:quran_gate_academy/features/dashboard/domain/repositories/student_dashboard_repository.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/student_dashboard_state.dart';
import 'package:quran_gate_academy/features/teachers/domain/repositories/teacher_repository.dart';

/// Student Dashboard Cubit - Manages student dashboard state
class StudentDashboardCubit extends Cubit<StudentDashboardState> {
  final StudentDashboardRepository studentDashboardRepository;
  final TeacherRepository teacherRepository;

  StudentDashboardCubit({
    required this.studentDashboardRepository,
    required this.teacherRepository,
  }) : super(StudentDashboardInitial());

  /// Load student dashboard with personal statistics
  Future<void> loadDashboard({required String studentId}) async {
    emit(StudentDashboardLoading());
    try {
      // Fetch student-specific data (filtered by studentId)
      final stats = await studentDashboardRepository.getDashboardStats(
        studentId: studentId,
      );

      final todaySessions = await studentDashboardRepository.getTodaySessions(
        studentId: studentId,
      );

      final upcomingSessions =
          await studentDashboardRepository.getUpcomingSessions(
        studentId: studentId,
      );

      // Fetch teacher names if missing
      final allDashboardSessions = [...todaySessions, ...upcomingSessions];
      final missingTeacherIds = allDashboardSessions
          .map((s) => s.teacherId)
          .where((id) => !NameCache.hasTeacher(id))
          .toSet();

      if (missingTeacherIds.isNotEmpty) {
        final allTeachers = await teacherRepository.getAllTeachers();
        for (var t in allTeachers) {
          NameCache.cacheTeacherName(t.id, t.fullName);
        }
      }

      // Populate teacher names
      final populatedTodaySessions = todaySessions.map((session) {
        return session.copyWith(
          teacherName:
              NameCache.getTeacherName(session.teacherId) ?? 'Unknown Teacher',
        );
      }).toList();

      final populatedUpcomingSessions = upcomingSessions.map((session) {
        return session.copyWith(
          teacherName:
              NameCache.getTeacherName(session.teacherId) ?? 'Unknown Teacher',
        );
      }).toList();

      emit(StudentDashboardLoaded(
        stats: stats,
        todaySessions: populatedTodaySessions,
        upcomingSessions: populatedUpcomingSessions,
      ));
    } catch (e) {
      emit(StudentDashboardError('Failed to load dashboard: ${e.toString()}'));
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard({required String studentId}) async {
    // If already loaded, refresh in place
    final currentState = state;
    if (currentState is StudentDashboardLoaded) {
      await loadDashboard(studentId: studentId);
    } else {
      await loadDashboard(studentId: studentId);
    }
  }

  /// Search sessions by date range
  Future<void> searchSessionsByDate({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    emit(StudentDashboardLoading());
    try {
      // Fetch sessions in date range
      final sessions = await studentDashboardRepository.getSessionsByDateRange(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );

      // Get stats (use full data for stats, not just date range)
      final stats = await studentDashboardRepository.getDashboardStats(
        studentId: studentId,
      );

      // Fetch teacher names if missing
      final missingTeacherIds = sessions
          .map((s) => s.teacherId)
          .where((id) => !NameCache.hasTeacher(id))
          .toSet();

      if (missingTeacherIds.isNotEmpty) {
        final allTeachers = await teacherRepository.getAllTeachers();
        for (var t in allTeachers) {
          NameCache.cacheTeacherName(t.id, t.fullName);
        }
      }

      // Populate teacher names
      final populatedSessions = sessions.map((session) {
        return session.copyWith(
          teacherName:
              NameCache.getTeacherName(session.teacherId) ?? 'Unknown Teacher',
        );
      }).toList();

      // Separate today and upcoming from search results
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final todaySessions = populatedSessions
          .where((s) =>
              s.scheduledDate.year == today.year &&
              s.scheduledDate.month == today.month &&
              s.scheduledDate.day == today.day)
          .toList();

      final upcomingSessions = populatedSessions
          .where((s) =>
              s.status == 'scheduled' && s.scheduledDate.isAfter(today))
          .toList();

      emit(StudentDashboardLoaded(
        stats: stats,
        todaySessions: todaySessions,
        upcomingSessions: upcomingSessions,
        searchStartDate: startDate,
        searchEndDate: endDate,
      ));
    } catch (e) {
      emit(StudentDashboardError(
          'Failed to search sessions: ${e.toString()}'));
    }
  }
}
