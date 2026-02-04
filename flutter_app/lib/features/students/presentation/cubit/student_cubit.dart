import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';
import 'package:quran_gate_academy/features/students/domain/repositories/student_repository.dart';
import 'package:quran_gate_academy/features/students/presentation/cubit/student_state.dart';
import 'package:appwrite/appwrite.dart';

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

  /// Create a new student with user account
  Future<void> createStudentWithAccount({
    required String fullName,
    String? email,
    String? phone,
    String? whatsapp,
    String? country,
    String? countryCode,
    String? timezone,
    String? profilePicture,
    String? notes,
    required String accountEmail,
    required String accountPassword,
  }) async {
    emit(StudentLoading());
    try {
      // Step 1: Create student record
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

      // Step 2: Create user account
      final account = AppConfig.account;
      final databases = AppConfig.databases;

      try {
        // Create auth account (without name to avoid uniqueness conflicts)
        final user = await account.create(
          userId: ID.unique(),
          email: accountEmail,
          password: accountPassword,
          name: fullName,
        );

        // Step 3: Create user document with role and linkedStudentId
        await databases.createDocument(
          databaseId: AppConfig.appwriteDatabaseId,
          collectionId: AppConfig.usersCollectionId,
          documentId: user.$id,
          data: {
            'userId':user.$id,
            'email': accountEmail,
            'fullName': fullName,
            'role': AppConfig.roleStudent,
            'linkedStudentId': student.id,
            'status': 'active',
            'createdAt': DateTime.now().toIso8601String(),
          },
        );

        // Step 4: Update student document with userId
        await databases.updateDocument(
          databaseId: AppConfig.appwriteDatabaseId,
          collectionId: AppConfig.studentsCollectionId,
          documentId: student.id,
          data: {
            'userId': user.$id,
          },
        );

        // Success! Emit state with credentials
        emit(StudentCreatedWithAccount(
          student: student,
          accountEmail: accountEmail,
          accountPassword: accountPassword,
        ));
      } catch (accountError) {
        // Account creation failed, rollback student creation
        try {
          await studentRepository.deleteStudent(student.id);
        } catch (rollbackError) {
          // Log rollback error but don't mask original error
        }

        // Parse and throw user-friendly error
        String errorMessage = 'Failed to create user account: ';
        final errorStr = accountError.toString().toLowerCase();

        if (errorStr.contains('rate limit') || errorStr.contains('too many requests')) {
          errorMessage += 'Too many account creation requests. Please wait a minute and try again.';
        } else if (errorStr.contains('email') && errorStr.contains('already')) {
          errorMessage += 'This email is already registered. Please use a different email address.';
        } else if (errorStr.contains('invalid email')) {
          errorMessage += 'Please enter a valid email address.';
        } else if (errorStr.contains('network')) {
          errorMessage += 'Network error. Please check your connection and try again.';
        } else {
          errorMessage += accountError.toString()
              .replaceAll('Exception: ', '')
              .replaceAll('AppwriteException: ', '');
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      emit(StudentError('Failed to create student with account: ${e.toString()}'));
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
