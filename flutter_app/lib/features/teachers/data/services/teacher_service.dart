import 'package:appwrite/appwrite.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';

/// Teacher Service - Handles all Appwrite operations for teachers
class TeacherService {
  final Account account;
  final Databases databases;

  TeacherService({
    required this.account,
    required this.databases,
  });

  /// Create a new teacher with Appwrite account
  Future<Map<String, dynamic>> createTeacher({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required double hourlyRate,
    String? specialization,
  }) async {
    try {
      // 1. Create Appwrite auth account
      final authUser = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: fullName,
      );

      // Get the user ID from the auth user
      final authUserId = authUser.$id;

      // 2. Create user document with role='teacher'
      final userResponse = await databases.createDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.usersCollectionId,
        documentId: ID.unique(),
        data: {
          'userId': authUserId,
          'role': AppConfig.roleTeacher,
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'hourlyRate': hourlyRate,
          'specialization': specialization,
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      return userResponse.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to create teacher: ${e.message}');
    }
  }

  /// Get teacher by ID
  Future<Map<String, dynamic>> getTeacher(String teacherId) async {
    try {
      final response = await databases.getDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.usersCollectionId,
        documentId: teacherId,
      );

      return response.data;
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        throw Exception('Teacher not found');
      }
      throw Exception('Failed to fetch teacher: ${e.message}');
    }
  }

  /// Get all teachers
  Future<List<Map<String, dynamic>>> getAllTeachers({
    String? status,
    int limit = 100,
  }) async {
    try {
      final queries = <String>[
        Query.equal('role', AppConfig.roleTeacher),
        Query.orderDesc('\$createdAt'),
        Query.limit(limit),
      ];

      if (status != null) {
        queries.add(Query.equal('status', status));
      }

      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.usersCollectionId,
        queries: queries,
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch teachers: ${e.message}');
    }
  }

  /// Update a teacher
  Future<Map<String, dynamic>> updateTeacher({
    required String teacherId,
    String? fullName,
    String? phone,
    double? hourlyRate,
    String? specialization,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (fullName != null) data['fullName'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (hourlyRate != null) data['hourlyRate'] = hourlyRate;
      if (specialization != null) data['specialization'] = specialization;
      if (status != null) data['status'] = status;

      final response = await databases.updateDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.usersCollectionId,
        documentId: teacherId,
        data: data,
      );

      return response.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to update teacher: ${e.message}');
    }
  }

  /// Deactivate a teacher (soft delete)
  Future<Map<String, dynamic>> deactivateTeacher(String teacherId) async {
    try {
      final response = await databases.updateDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.usersCollectionId,
        documentId: teacherId,
        data: {
          'status': 'inactive',
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      return response.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to deactivate teacher: ${e.message}');
    }
  }

  /// Activate a teacher
  Future<Map<String, dynamic>> activateTeacher(String teacherId) async {
    try {
      final response = await databases.updateDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.usersCollectionId,
        documentId: teacherId,
        data: {
          'status': 'active',
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      return response.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to activate teacher: ${e.message}');
    }
  }

  /// Get active teachers count
  Future<int> getActiveTeachersCount() async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.usersCollectionId,
        queries: [
          Query.equal('role', AppConfig.roleTeacher),
          Query.equal('status', 'active'),
        ],
      );

      return response.total;
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch active teachers count: ${e.message}');
    }
  }
}
