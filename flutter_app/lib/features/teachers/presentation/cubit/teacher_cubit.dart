import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/features/teachers/domain/repositories/teacher_repository.dart';
import 'package:quran_gate_academy/features/teachers/presentation/cubit/teacher_state.dart';

/// Teacher Cubit - Manages teacher state and business logic
class TeacherCubit extends Cubit<TeacherState> {
  final TeacherRepository teacherRepository;

  TeacherCubit({required this.teacherRepository}) : super(TeacherInitial());

  /// Load all teachers with optional filters
  Future<void> loadTeachers({
    String? status,
  }) async {
    emit(TeacherLoading());
    try {
      final teachers = await teacherRepository.getAllTeachers(
        status: status,
      );
      emit(TeachersLoaded(teachers));
    } catch (e) {
      emit(TeacherError('Failed to load teachers: ${e.toString()}'));
    }
  }

  /// Load a single teacher
  Future<void> loadTeacher(String teacherId) async {
    emit(TeacherLoading());
    try {
      final teacher = await teacherRepository.getTeacher(teacherId);
      emit(TeacherLoaded(teacher));
    } catch (e) {
      emit(TeacherError('Failed to load teacher: ${e.toString()}'));
    }
  }

  /// Create a new teacher
  Future<void> createTeacher({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required double hourlyRate,
    String? specialization,
  }) async {
    emit(TeacherLoading());
    try {
      final teacher = await teacherRepository.createTeacher(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        hourlyRate: hourlyRate,
        specialization: specialization,
      );
      emit(TeacherCreated(teacher));
    } catch (e) {
      emit(TeacherError('Failed to create teacher: ${e.toString()}'));
    }
  }

  /// Update an existing teacher
  Future<void> updateTeacher({
    required String teacherId,
    String? fullName,
    String? phone,
    double? hourlyRate,
    String? specialization,
    String? status,
  }) async {
    emit(TeacherLoading());
    try {
      final teacher = await teacherRepository.updateTeacher(
        teacherId: teacherId,
        fullName: fullName,
        phone: phone,
        hourlyRate: hourlyRate,
        specialization: specialization,
        status: status,
      );
      emit(TeacherUpdated(teacher));
    } catch (e) {
      emit(TeacherError('Failed to update teacher: ${e.toString()}'));
    }
  }

  /// Deactivate a teacher
  Future<void> deactivateTeacher(String teacherId) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.deactivateTeacher(teacherId);
      emit(TeacherDeactivated());
    } catch (e) {
      emit(TeacherError('Failed to deactivate teacher: ${e.toString()}'));
    }
  }

  /// Activate a teacher
  Future<void> activateTeacher(String teacherId) async {
    emit(TeacherLoading());
    try {
      await teacherRepository.activateTeacher(teacherId);
      emit(TeacherActivated());
    } catch (e) {
      emit(TeacherError('Failed to activate teacher: ${e.toString()}'));
    }
  }

  /// Refresh teachers list
  Future<void> refreshTeachers({String? status}) async {
    await loadTeachers(status: status);
  }
}
