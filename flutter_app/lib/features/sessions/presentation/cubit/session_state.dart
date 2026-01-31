import 'package:equatable/equatable.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';

/// Session states
abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionsLoaded extends SessionState {
  final List<ClassSessionModel> sessions;

  const SessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class SessionLoaded extends SessionState {
  final ClassSessionModel session;

  const SessionLoaded(this.session);

  @override
  List<Object?> get props => [session];
}

class SessionCreated extends SessionState {
  final ClassSessionModel session;

  const SessionCreated(this.session);

  @override
  List<Object?> get props => [session];
}

class SessionUpdated extends SessionState {
  final ClassSessionModel session;

  const SessionUpdated(this.session);

  @override
  List<Object?> get props => [session];
}

class SessionDeleted extends SessionState {}

class SessionError extends SessionState {
  final String message;

  const SessionError(this.message);

  @override
  List<Object?> get props => [message];
}
