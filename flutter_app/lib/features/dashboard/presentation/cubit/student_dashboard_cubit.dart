import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/core/utils/name_cache.dart';
import 'package:quran_gate_academy/features/dashboard/domain/repositories/student_dashboard_repository.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/student_dashboard_state.dart';
import 'package:quran_gate_academy/features/teachers/domain/repositories/teacher_repository.dart';

/// Cubit for managing student dashboard state
class StudentDashboardCubit extends Cubit<StudentDashboardState> {
  final StudentDashboardRepository studentDashboardRepository;
  final TeacherRepository teacherRepository;

  StudentDashboardCubit({
    required this.studentDashboardRepository,
    required this.teacherRepository,
  }) : super(StudentDashboardInitial());

  /// Load student dashboard data
  Future<void> loadDashboard({required String studentId}) async {
    emit(StudentDashboardLoading());
    try {
      // Fetch dashboard stats
      final stats = await studentDashboardRepository.getDashboardStats(
        studentId: studentId,
      );

      // Fetch today's sessions
      final todaySessions = await studentDashboardRepository.getTodaySessions(
        studentId: studentId,
      );

      // Fetch upcoming sessions (limit to 5 for dashboard)
      final allUpcoming = await studentDashboardRepository.getUpcomingSessions(
        studentId: studentId,
      );
      final upcomingSessions = allUpcoming.take(5).toList();

      // Cache teacher names for sessions
      final allDashboardSessions = [...todaySessions, ...upcomingSessions];
      final missingTeacherIds = allDashboardSessions
          .map((s) => s.teacherId)
          .where((id) => !NameCache.hasTeacher(id))
          .toSet();

      if (missingTeacherIds.isNotEmpty) {
        final allTeachers = await teacherRepository.getAllTeachers();
        for (var teacher in allTeachers) {
          NameCache.cacheTeacherName(teacher.id, teacher.fullName);
        }
      }

      // Populate teacher names in sessions
      final populatedTodaySessions = todaySessions.map((session) {
        return session.copyWith(
          teacherName: NameCache.getTeacherName(session.teacherId) ?? 'Unknown Teacher',
        );
      }).toList();

      final populatedUpcomingSessions = upcomingSessions.map((session) {
        return session.copyWith(
          teacherName: NameCache.getTeacherName(session.teacherId) ?? 'Unknown Teacher',
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
    await loadDashboard(studentId: studentId);
  }
}
