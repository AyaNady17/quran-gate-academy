import 'package:appwrite/appwrite.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';

/// Student service - Handles student-related API calls
class StudentService {
  final Databases databases;
  final Account account;

  StudentService({
    required this.databases,
    required this.account,
  });

  /// Get all students with optional status filter
  Future<List<Map<String, dynamic>>> getAllStudents({
    String? status,
    int limit = 100,
  }) async {
    try {
      final queries = <String>[
        Query.orderDesc('\$createdAt'),
        Query.limit(limit),
      ];

      if (status != null) {
        queries.add(Query.equal('status', status));
      } else {
        // By default, don't show inactive (deleted) students
        queries.add(Query.notEqual('status', 'inactive'));
      }

      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.studentsCollectionId,
        queries: queries,
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch students: ${e.message}');
    }
  }

  /// Get student by ID
  Future<Map<String, dynamic>> getStudent(String studentId) async {
    try {
      final response = await databases.getDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.studentsCollectionId,
        documentId: studentId,
      );

      return response.data;
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        throw Exception('Student not found');
      }
      throw Exception('Failed to fetch student: ${e.message}');
    }
  }

  /// Create a new student
  Future<Map<String, dynamic>> createStudent({
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
      final response = await databases.createDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.studentsCollectionId,
        documentId: ID.unique(),
        data: {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'whatsapp': whatsapp,
          'country': country,
          'countryCode': countryCode,
          'timezone': timezone,
          'profilePicture': profilePicture,
          'status': 'active',
          'notes': notes,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      return response.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to create student: ${e.message}');
    }
  }

  /// Update an existing student
  Future<Map<String, dynamic>> updateStudent({
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
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['fullName'] = fullName;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (whatsapp != null) updateData['whatsapp'] = whatsapp;
      if (country != null) updateData['country'] = country;
      if (countryCode != null) updateData['countryCode'] = countryCode;
      if (timezone != null) updateData['timezone'] = timezone;
      if (profilePicture != null) updateData['profilePicture'] = profilePicture;
      if (status != null) updateData['status'] = status;
      if (notes != null) updateData['notes'] = notes;

      final response = await databases.updateDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.studentsCollectionId,
        documentId: studentId,
        data: updateData,
      );

      return response.data;
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        throw Exception('Student not found');
      }
      throw Exception('Failed to update student: ${e.message}');
    }
  }

  /// Delete a student (soft delete by setting status to 'inactive')
  Future<void> deleteStudent(String studentId) async {
    try {
      await databases.updateDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.studentsCollectionId,
        documentId: studentId,
        data: {
          'status': 'inactive',
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        throw Exception('Student not found');
      }
      throw Exception('Failed to delete student: ${e.message}');
    }
  }

  /// Create user account for an existing student
  Future<Map<String, dynamic>> createUserAccount({
    required String studentId,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // 1. Create Appwrite auth account
      final authUser = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: fullName,
      );

      final authUserId = authUser.$id;

      // 2. Create user document with role='student' and linkedStudentId
      final userResponse = await databases.createDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.usersCollectionId,
        documentId: ID.unique(),
        data: {
          'userId': authUserId,
          'role': AppConfig.roleStudent,
          'fullName': fullName,
          'email': email,
          'linkedStudentId': studentId,
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      final userDocId = userResponse.data['\$id'];

      // 3. Update student document with userId (bidirectional link)
      await databases.updateDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.studentsCollectionId,
        documentId: studentId,
        data: {
          'userId': userDocId,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      return userResponse.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to create user account: ${e.message}');
    }
  }
}
