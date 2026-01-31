import 'package:quran_gate_academy/core/models/teacher_model.dart';
import 'package:quran_gate_academy/features/teachers/data/services/teacher_service.dart';
import 'package:quran_gate_academy/features/teachers/domain/repositories/teacher_repository.dart';

/// Teacher repository implementation
class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherService teacherService;

  TeacherRepositoryImpl({required this.teacherService});

  @override
  Future<TeacherModel> createTeacher({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required double hourlyRate,
    String? specialization,
  }) async {
    try {
      final teacherData = await teacherService.createTeacher(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        hourlyRate: hourlyRate,
        specialization: specialization,
      );

      return TeacherModel.fromJson(teacherData);
    } catch (e) {
      throw Exception('Failed to create teacher: $e');
    }
  }

  @override
  Future<TeacherModel> getTeacher(String teacherId) async {
    try {
      final teacherData = await teacherService.getTeacher(teacherId);
      return TeacherModel.fromJson(teacherData);
    } catch (e) {
      throw Exception('Failed to get teacher: $e');
    }
  }

  @override
  Future<List<TeacherModel>> getAllTeachers({
    String? status,
    int limit = 100,
  }) async {
    try {
      final teachersData = await teacherService.getAllTeachers(
        status: status,
        limit: limit,
      );

      return teachersData
          .map((data) => TeacherModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all teachers: $e');
    }
  }

  @override
  Future<TeacherModel> updateTeacher({
    required String teacherId,
    String? fullName,
    String? phone,
    double? hourlyRate,
    String? specialization,
    String? status,
  }) async {
    try {
      final teacherData = await teacherService.updateTeacher(
        teacherId: teacherId,
        fullName: fullName,
        phone: phone,
        hourlyRate: hourlyRate,
        specialization: specialization,
        status: status,
      );

      return TeacherModel.fromJson(teacherData);
    } catch (e) {
      throw Exception('Failed to update teacher: $e');
    }
  }

  @override
  Future<TeacherModel> deactivateTeacher(String teacherId) async {
    try {
      final teacherData = await teacherService.deactivateTeacher(teacherId);
      return TeacherModel.fromJson(teacherData);
    } catch (e) {
      throw Exception('Failed to deactivate teacher: $e');
    }
  }

  @override
  Future<TeacherModel> activateTeacher(String teacherId) async {
    try {
      final teacherData = await teacherService.activateTeacher(teacherId);
      return TeacherModel.fromJson(teacherData);
    } catch (e) {
      throw Exception('Failed to activate teacher: $e');
    }
  }

  @override
  Future<int> getActiveTeachersCount() async {
    try {
      return await teacherService.getActiveTeachersCount();
    } catch (e) {
      throw Exception('Failed to get active teachers count: $e');
    }
  }
}
