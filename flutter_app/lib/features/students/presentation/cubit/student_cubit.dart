import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/features/students/domain/repositories/student_repository.dart';
import 'package:quran_gate_academy/features/students/presentation/cubit/student_state.dart';

/// Student Cubit
class StudentCubit extends Cubit<StudentState> {
  final StudentRepository studentRepository;

  StudentCubit({required this.studentRepository}) : super(StudentInitial());

  /// Load all students
  Future<void> loadStudents({String? status}) async {
    emit(StudentLoading());
    try {
      final students = await studentRepository.getAllStudents(status: status);
      emit(StudentsLoaded(students));
    } catch (e) {
      emit(StudentError('Failed to load students: ${e.toString()}'));
    }
  }

  /// Load single student
  Future<void> loadStudent(String studentId) async {
    emit(StudentLoading());
    try {
      final student = await studentRepository.getStudent(studentId);
      emit(StudentLoaded(student));
    } catch (e) {
      emit(StudentError('Failed to load student: ${e.toString()}'));
    }
  }

  /// Create a new student
  Future<void> createStudent({
    required String fullName,
    String? email,
    String? phone,
    String? whatsapp,
    String? country,
    String? countryCode,
    String? timezone,
    String? profilePicture,
    String? notes,
  }) async {
    emit(StudentLoading());
    try {
      final student = await studentRepository.createStudent(
        fullName: fullName,
        email: email,
        phone: phone,
        whatsapp: whatsapp,
        country: country,
        countryCode: countryCode,
        timezone: timezone,
        profilePicture: profilePicture,
        notes: notes,
      );
      emit(StudentCreated(student));
    } catch (e) {
      emit(StudentError('Failed to create student: ${e.toString()}'));
    }
  }

  /// Update an existing student
  Future<void> updateStudent({
    required String studentId,
    String? fullName,
    String? email,
    String? phone,
    String? whatsapp,
    String? country,
    String? countryCode,
    String? timezone,
    String? profilePicture,
    String? status,
    String? notes,
  }) async {
    emit(StudentLoading());
    try {
      final student = await studentRepository.updateStudent(
        studentId: studentId,
        fullName: fullName,
        email: email,
        phone: phone,
        whatsapp: whatsapp,
        country: country,
        countryCode: countryCode,
        timezone: timezone,
        profilePicture: profilePicture,
        status: status,
        notes: notes,
      );
      emit(StudentUpdated(student));
    } catch (e) {
      emit(StudentError('Failed to update student: ${e.toString()}'));
    }
  }

  /// Delete a student
  Future<void> deleteStudent(String studentId) async {
    emit(StudentLoading());
    try {
      await studentRepository.deleteStudent(studentId);
      emit(StudentDeleted());
    } catch (e) {
      emit(StudentError('Failed to delete student: ${e.toString()}'));
    }
  }

  /// Refresh students list
  Future<void> refreshStudents({String? status}) async {
    await loadStudents(status: status);
  }
}
