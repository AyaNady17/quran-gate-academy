import 'package:equatable/equatable.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Dashboard states
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<ClassSessionModel> todaySessions;

  const DashboardLoaded({
    required this.stats,
    required this.todaySessions,
  });

  @override
  List<Object?> get props => [stats, todaySessions];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
