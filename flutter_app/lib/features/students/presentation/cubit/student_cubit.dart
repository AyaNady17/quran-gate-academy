import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/features/students/domain/repositories/student_repository.dart';
import 'package:quran_gate_academy/features/students/presentation/cubit/student_state.dart';

/// Student Cubit
class StudentCubit extends Cubit<StudentState> {
  final StudentRepository studentRepository;

  StudentCubit({required this.studentRepository}) : super(StudentInitial());
}
