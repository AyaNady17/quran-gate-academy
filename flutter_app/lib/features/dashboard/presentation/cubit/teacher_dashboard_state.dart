import 'package:equatable/equatable.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';

/// Teacher Dashboard State
abstract class TeacherDashboardState extends Equatable {
  const TeacherDashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TeacherDashboardInitial extends TeacherDashboardState {}

/// Loading state
class TeacherDashboardLoading extends TeacherDashboardState {}

/// Loaded state with teacher statistics
class TeacherDashboardLoaded extends TeacherDashboardState {
  final TeacherDashboardStats stats;
  final List<ClassSessionModel> todaySessions;
  final List<ClassSessionModel> upcomingSessions;
  final DateTime? searchStartDate;
  final DateTime? searchEndDate;

  const TeacherDashboardLoaded({
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
class TeacherDashboardError extends TeacherDashboardState {
  final String message;

  const TeacherDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Teacher Dashboard Statistics Model
class TeacherDashboardStats extends Equatable {
  final double totalHours;
  final double totalSalary;
  final double attendancePercentage;
  final int totalSessions;
  final int completedSessions;
  final int todaySessionsCount;
  final int upcomingSessionsCount;
  final double monthlyHours;
  final double monthlySalary;

  const TeacherDashboardStats({
    required this.totalHours,
    required this.totalSalary,
    required this.attendancePercentage,
    required this.totalSessions,
    required this.completedSessions,
    required this.todaySessionsCount,
    required this.upcomingSessionsCount,
    required this.monthlyHours,
    required this.monthlySalary,
  });

  @override
  List<Object?> get props => [
        totalHours,
        totalSalary,
        attendancePercentage,
        totalSessions,
        completedSessions,
        todaySessionsCount,
        upcomingSessionsCount,
        monthlyHours,
        monthlySalary,
      ];
}
