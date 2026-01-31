import 'package:quran_gate_academy/features/students/data/services/student_service.dart';
import 'package:quran_gate_academy/features/students/domain/repositories/student_repository.dart';

/// Student repository implementation
class StudentRepositoryImpl implements StudentRepository {
  final StudentService studentService;

  StudentRepositoryImpl({required this.studentService});
}
