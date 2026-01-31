import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/dashboard_state.dart';

/// Dashboard Cubit - Manages dashboard state and business logic
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository dashboardRepository;

  DashboardCubit({required this.dashboardRepository}) : super(DashboardInitial());

  /// Load dashboard data for a specific teacher
  Future<void> loadDashboard({required String teacherId}) async {
    emit(DashboardLoading());

    try {
      // Fetch dashboard stats and today's sessions in parallel
      final results = await Future.wait([
        dashboardRepository.getDashboardStats(teacherId: teacherId),
        dashboardRepository.getTodaySessions(teacherId: teacherId),
      ]);

      final stats = results[0] as DashboardStats;
      final todaySessions = results[1] as List;

      emit(DashboardLoaded(
        stats: stats,
        todaySessions: todaySessions.cast(),
      ));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard: ${e.toString()}'));
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard({required String teacherId}) async {
    await loadDashboard(teacherId: teacherId);
  }
}
