import 'package:equatable/equatable.dart';
import 'package:quran_gate_academy/core/models/session_report_model.dart';

/// Base state for session reports
abstract class SessionReportState extends Equatable {
  const SessionReportState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SessionReportInitial extends SessionReportState {}

/// Loading state
class SessionReportLoading extends SessionReportState {}

/// Report created successfully
class SessionReportCreated extends SessionReportState {
  final SessionReportModel report;

  const SessionReportCreated(this.report);

  @override
  List<Object?> get props => [report];
}

/// Reports loaded
class SessionReportsLoaded extends SessionReportState {
  final List<SessionReportModel> reports;

  const SessionReportsLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

/// Single report loaded
class SessionReportLoaded extends SessionReportState {
  final SessionReportModel? report;

  const SessionReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

/// Report updated
class SessionReportUpdated extends SessionReportState {
  final SessionReportModel report;

  const SessionReportUpdated(this.report);

  @override
  List<Object?> get props => [report];
}

/// Report deleted
class SessionReportDeleted extends SessionReportState {}

/// Error state
class SessionReportError extends SessionReportState {
  final String message;

  const SessionReportError(this.message);

  @override
  List<Object?> get props => [message];
}
