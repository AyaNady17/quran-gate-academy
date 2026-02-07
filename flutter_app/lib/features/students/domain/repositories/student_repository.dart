import 'package:quran_gate_academy/core/models/student_model.dart';

/// Student repository interface
abstract class StudentRepository {
  /// Get all students
  Future<List<StudentModel>> getAllStudents({String? status});

  /// Get student by ID
  Future<StudentModel> getStudent(String studentId);

  /// Create a new student
  Future<StudentModel> createStudent({
    required String fullName,
    String? email,
    String? phone,
    String? whatsapp,
    String? country,
    String? countryCode,
    String? timezone,
    String? profilePicture,
    String? notes,
  });

  /// Update an existing student
  Future<StudentModel> updateStudent({
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
  });

  /// Delete a student (soft delete)
  Future<void> deleteStudent(String studentId);

  /// Create user account for an existing student
  Future<void> createUserAccount({
    required String studentId,
    required String email,
    required String password,
    required String fullName,
  });
}
