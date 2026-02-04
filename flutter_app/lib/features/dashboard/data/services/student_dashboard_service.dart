import 'package:appwrite/appwrite.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';

/// Service for fetching student dashboard data
class StudentDashboardService {
  final Databases databases;

  StudentDashboardService({required this.databases});

  /// Get all sessions for a specific student
  Future<List<Map<String, dynamic>>> getStudentSessions({
    required String studentId,
  }) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: [
          Query.equal('studentId', studentId),
          Query.orderDesc('scheduledDate'),
          Query.limit(100),
        ],
      );
      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch student sessions: ${e.message}');
    }
  }

  /// Get upcoming sessions for student (scheduled sessions after now)
  Future<List<Map<String, dynamic>>> getUpcomingSessions({
    required String studentId,
  }) async {
    try {
      final now = DateTime.now();
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: [
          Query.equal('studentId', studentId),
          Query.equal('status', AppConfig.sessionStatusScheduled),
          Query.greaterThanEqual('scheduledDate', now.toIso8601String()),
          Query.orderAsc('scheduledDate'),
          Query.limit(50),
        ],
      );
      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch upcoming sessions: ${e.message}');
    }
  }

  /// Get completed sessions for student
  Future<List<Map<String, dynamic>>> getCompletedSessions({
    required String studentId,
  }) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: [
          Query.equal('studentId', studentId),
          Query.equal('status', AppConfig.sessionStatusCompleted),
          Query.orderDesc('scheduledDate'),
          Query.limit(100),
        ],
      );
      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch completed sessions: ${e.message}');
    }
  }

  /// Get today's sessions for student
  Future<List<Map<String, dynamic>>> getTodaySessions({
    required String studentId,
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: [
          Query.equal('studentId', studentId),
          Query.greaterThanEqual('scheduledDate', today.toIso8601String()),
          Query.lessThan('scheduledDate', tomorrow.toIso8601String()),
          Query.orderAsc('scheduledTime'),
        ],
      );
      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch today\'s sessions: ${e.message}');
    }
  }
}
