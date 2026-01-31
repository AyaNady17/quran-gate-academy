import 'package:equatable/equatable.dart';
import 'package:quran_gate_academy/core/models/teacher_model.dart';

/// Base teacher state
abstract class TeacherState extends Equatable {
  const TeacherState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TeacherInitial extends TeacherState {}

/// Loading state
class TeacherLoading extends TeacherState {}

/// Teachers loaded state
class TeachersLoaded extends TeacherState {
  final List<TeacherModel> teachers;

  const TeachersLoaded(this.teachers);

  @override
  List<Object?> get props => [teachers];
}

/// Single teacher loaded state
class TeacherLoaded extends TeacherState {
  final TeacherModel teacher;

  const TeacherLoaded(this.teacher);

  @override
  List<Object?> get props => [teacher];
}

/// Teacher created state
class TeacherCreated extends TeacherState {
  final TeacherModel teacher;

  const TeacherCreated(this.teacher);

  @override
  List<Object?> get props => [teacher];
}

/// Teacher updated state
class TeacherUpdated extends TeacherState {
  final TeacherModel teacher;

  const TeacherUpdated(this.teacher);

  @override
  List<Object?> get props => [teacher];
}

/// Teacher deactivated state
class TeacherDeactivated extends TeacherState {}

/// Teacher activated state
class TeacherActivated extends TeacherState {}

/// Error state
class TeacherError extends TeacherState {
  final String message;

  const TeacherError(this.message);

  @override
  List<Object?> get props => [message];
}
