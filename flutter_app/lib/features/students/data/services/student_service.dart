import 'package:appwrite/appwrite.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';

/// Student service - Handles student-related API calls
class StudentService {
  final Databases databases;

  StudentService({required this.databases});

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
}
