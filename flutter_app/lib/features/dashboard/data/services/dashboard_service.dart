import 'package:appwrite/appwrite.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';

/// Dashboard Service - Handles all Appwrite operations for dashboard data
class DashboardService {
  final Databases databases;

  DashboardService({required this.databases});

  /// Fetch all sessions for a specific teacher
  Future<List<Map<String, dynamic>>> getTeacherSessions({
    required String teacherId,
  }) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: [
          Query.equal('teacherId', teacherId),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch teacher sessions: ${e.message}');
    }
  }

  /// Fetch completed sessions for a teacher
  Future<List<Map<String, dynamic>>> getCompletedSessions({
    required String teacherId,
  }) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: [
          Query.equal('teacherId', teacherId),
          Query.equal('status', AppConfig.sessionStatusCompleted),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch completed sessions: ${e.message}');
    }
  }

  /// Fetch today's sessions for a teacher
  Future<List<Map<String, dynamic>>> getTodaySessions({
    required String teacherId,
  }) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: [
          Query.equal('teacherId', teacherId),
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

  /// Fetch student details by ID
  Future<Map<String, dynamic>?> getStudent(String studentId) async {
    try {
      final response = await databases.getDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.studentsCollectionId,
        documentId: studentId,
      );

      return response.data;
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        return null; // Student not found
      }
      throw Exception('Failed to fetch student: ${e.message}');
    }
  }

  /// Fetch course details by ID
  Future<Map<String, dynamic>?> getCourse(String courseId) async {
    try {
      final response = await databases.getDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.coursesCollectionId,
        documentId: courseId,
      );

      return response.data;
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        return null; // Course not found
      }
      throw Exception('Failed to fetch course: ${e.message}');
    }
  }

  /// Fetch weekly sessions for a teacher
  Future<List<Map<String, dynamic>>> getWeeklySessions({
    required String teacherId,
  }) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday % 7));
      final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final weekEnd = weekStartDate.add(const Duration(days: 7));

      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: [
          Query.equal('teacherId', teacherId),
          Query.greaterThanEqual('scheduledDate', weekStartDate.toIso8601String()),
          Query.lessThan('scheduledDate', weekEnd.toIso8601String()),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch weekly sessions: ${e.message}');
    }
  }

  /// Fetch monthly sessions for a teacher
  Future<List<Map<String, dynamic>>> getMonthlySessions({
    required String teacherId,
  }) async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: [
          Query.equal('teacherId', teacherId),
          Query.greaterThanEqual('scheduledDate', monthStart.toIso8601String()),
          Query.lessThanEqual('scheduledDate', monthEnd.toIso8601String()),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch monthly sessions: ${e.message}');
    }
  }

  /// Fetch all sessions (for admin only)
  /// [isAdminRequest] must be true - this method is admin-only
  Future<List<Map<String, dynamic>>> getAllSessions({
    bool isAdminRequest = false,
  }) async {
    // SECURITY: This method is admin-only, enforce the flag
    if (!isAdminRequest) {
      throw Exception('getAllSessions is an admin-only operation');
    }

    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: [
          Query.orderDesc('\$createdAt'),
          Query.limit(100),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch all sessions: ${e.message}');
    }
  }
}
