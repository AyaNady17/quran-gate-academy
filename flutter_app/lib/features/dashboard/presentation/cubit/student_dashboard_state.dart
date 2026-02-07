import 'package:equatable/equatable.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/features/dashboard/domain/repositories/student_dashboard_repository.dart';

/// Student Dashboard State
abstract class StudentDashboardState extends Equatable {
  const StudentDashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class StudentDashboardInitial extends StudentDashboardState {}

/// Loading state
class StudentDashboardLoading extends StudentDashboardState {}

/// Loaded state with student statistics
class StudentDashboardLoaded extends StudentDashboardState {
  final StudentDashboardStats stats;
  final List<ClassSessionModel> todaySessions;
  final List<ClassSessionModel> upcomingSessions;
  final DateTime? searchStartDate;
  final DateTime? searchEndDate;

  const StudentDashboardLoaded({
    required this.stats,
    required this.todaySessions,
    required this.upcomingSessions,
    this.searchStartDate,
    this.searchEndDate,
  });

  @override
  List<Object?> get props => [
        stats,
        todaySessions,
        upcomingSessions,
        searchStartDate,
        searchEndDate,
      ];
}

/// Error state
class StudentDashboardError extends StudentDashboardState {
  final String message;

  const StudentDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
