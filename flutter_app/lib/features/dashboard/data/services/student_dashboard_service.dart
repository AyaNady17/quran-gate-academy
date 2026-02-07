import 'package:appwrite/appwrite.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';

/// Student Dashboard Service - Handles all Appwrite operations for student dashboard data
class StudentDashboardService {
  final Databases databases;

  StudentDashboardService({required this.databases});

  /// Fetch all sessions for a specific student
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
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch student sessions: ${e.message}');
    }
  }

  /// Fetch upcoming sessions for a student (scheduled status, future dates)
  Future<List<Map<String, dynamic>>> getUpcomingSessions({
    required String studentId,
    int limit = 50,
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: [
          Query.equal('studentId', studentId),
          Query.equal('status', AppConfig.sessionStatusScheduled),
          Query.greaterThanEqual('scheduledDate', today.toIso8601String()),
          Query.orderAsc('scheduledDate'),
          Query.limit(limit),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch upcoming sessions: ${e.message}');
    }
  }

  /// Fetch completed sessions for a student
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
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch completed sessions: ${e.message}');
    }
  }

  /// Fetch today's sessions for a student
  Future<List<Map<String, dynamic>>> getTodaySessions({
    required String studentId,
  }) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: [
          Query.equal('studentId', studentId),
          Query.greaterThanEqual('scheduledDate', todayStart.toIso8601String()),
          Query.lessThanEqual('scheduledDate', todayEnd.toIso8601String()),
          Query.orderAsc('scheduledTime'),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch today\'s sessions: ${e.message}');
    }
  }

  /// Fetch sessions within a date range for a student
  Future<List<Map<String, dynamic>>> getSessionsByDateRange({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: [
          Query.equal('studentId', studentId),
          Query.greaterThanEqual('scheduledDate', startDate.toIso8601String()),
          Query.lessThanEqual('scheduledDate', endDate.toIso8601String()),
          Query.orderAsc('scheduledDate'),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch sessions by date range: ${e.message}');
    }
  }

  /// Fetch teacher details by ID (for displaying teacher names in sessions)
  Future<Map<String, dynamic>?> getTeacher(String teacherId) async {
    try {
      final response = await databases.getDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.usersCollectionId,
        documentId: teacherId,
      );

      return response.data;
    } on AppwriteException catch (e) {
      if (e.code == 404) return null;
      throw Exception('Failed to fetch teacher: ${e.message}');
    }
  }

  /// Fetch all teachers (for name caching)
  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.usersCollectionId,
        queries: [
          Query.equal('role', AppConfig.roleTeacher),
          Query.limit(500),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch teachers: ${e.message}');
    }
  }
}
