import 'package:quran_gate_academy/core/models/student_model.dart';
import 'package:quran_gate_academy/features/students/data/services/student_service.dart';
import 'package:quran_gate_academy/features/students/domain/repositories/student_repository.dart';

/// Student repository implementation
class StudentRepositoryImpl implements StudentRepository {
  final StudentService studentService;

  StudentRepositoryImpl({required this.studentService});

  @override
  Future<List<StudentModel>> getAllStudents({String? status}) async {
    try {
      final studentsData = await studentService.getAllStudents(status: status);
      return studentsData.map((data) => StudentModel.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StudentModel> getStudent(String studentId) async {
    try {
      final studentData = await studentService.getStudent(studentId);
      return StudentModel.fromJson(studentData);
    } catch (e) {
      rethrow;
    }
  }

  @override
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
  }) async {
    try {
      final studentData = await studentService.createStudent(
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
      return StudentModel.fromJson(studentData);
    } catch (e) {
      rethrow;
    }
  }

  @override
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
  }) async {
    try {
      final studentData = await studentService.updateStudent(
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
      return StudentModel.fromJson(studentData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    try {
      await studentService.deleteStudent(studentId);
    } catch (e) {
      rethrow;
    }
  }
}
