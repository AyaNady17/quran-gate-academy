import 'package:quran_gate_academy/core/models/teacher_model.dart';

/// Teacher repository interface
abstract class TeacherRepository {
  /// Create a new teacher
  Future<TeacherModel> createTeacher({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required double hourlyRate,
    String? specialization,
  });

  /// Get teacher by ID
  Future<TeacherModel> getTeacher(String teacherId);

  /// Get all teachers with optional filters
  Future<List<TeacherModel>> getAllTeachers({
    String? status,
    int limit = 100,
  });

  /// Update a teacher
  Future<TeacherModel> updateTeacher({
    required String teacherId,
    String? fullName,
    String? phone,
    double? hourlyRate,
    String? specialization,
    String? status,
  });

  /// Deactivate a teacher (soft delete)
  Future<TeacherModel> deactivateTeacher(String teacherId);

  /// Activate a teacher
  Future<TeacherModel> activateTeacher(String teacherId);

  /// Get active teachers count
  Future<int> getActiveTeachersCount();
}
