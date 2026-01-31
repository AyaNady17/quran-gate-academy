import 'package:equatable/equatable.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';

/// Admin Dashboard State
abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdminDashboardInitial extends AdminDashboardState {}

/// Loading state
class AdminDashboardLoading extends AdminDashboardState {}

/// Loaded state with admin statistics
class AdminDashboardLoaded extends AdminDashboardState {
  final AdminDashboardStats stats;
  final List<ClassSessionModel> recentSessions;

  const AdminDashboardLoaded({
    required this.stats,
    required this.recentSessions,
  });

  @override
  List<Object?> get props => [stats, recentSessions];
}

/// Error state
class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Admin Dashboard Statistics Model
class AdminDashboardStats extends Equatable {
  final int totalTeachers;
  final int activeTeachers;
  final int totalStudents;
  final int activeStudents;
  final int totalSessions;
  final int completedSessions;
  final int scheduledSessions;
  final double totalRevenue;
  final double monthlyRevenue;

  const AdminDashboardStats({
    required this.totalTeachers,
    required this.activeTeachers,
    required this.totalStudents,
    required this.activeStudents,
    required this.totalSessions,
    required this.completedSessions,
    required this.scheduledSessions,
    required this.totalRevenue,
    required this.monthlyRevenue,
  });

  @override
  List<Object?> get props => [
        totalTeachers,
        activeTeachers,
        totalStudents,
        activeStudents,
        totalSessions,
        completedSessions,
        scheduledSessions,
        totalRevenue,
        monthlyRevenue,
      ];
}
