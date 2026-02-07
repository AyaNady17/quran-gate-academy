import 'package:equatable/equatable.dart';
import 'package:quran_gate_academy/core/models/student_model.dart';

/// Student states
abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

/// Students list loaded
class StudentsLoaded extends StudentState {
  final List<StudentModel> students;

  const StudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

/// Single student loaded
class StudentLoaded extends StudentState {
  final StudentModel student;

  const StudentLoaded(this.student);

  @override
  List<Object?> get props => [student];
}

/// Student created successfully
class StudentCreated extends StudentState {
  final StudentModel student;

  const StudentCreated(this.student);

  @override
  List<Object?> get props => [student];
}

/// Student updated successfully
class StudentUpdated extends StudentState {
  final StudentModel student;

  const StudentUpdated(this.student);

  @override
  List<Object?> get props => [student];
}

/// Student deleted successfully
class StudentDeleted extends StudentState {}

/// User account created for student successfully
class StudentUserAccountCreated extends StudentState {}

class StudentError extends StudentState {
  final String message;

  const StudentError(this.message);

  @override
  List<Object?> get props => [message];
}
