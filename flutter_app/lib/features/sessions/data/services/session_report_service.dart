import 'package:appwrite/appwrite.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';

/// Service for managing session reports
class SessionReportService {
  final Databases databases;

  SessionReportService({required this.databases});

  /// Create a new session report
  Future<Map<String, dynamic>> createReport({
    required String sessionId,
    required String studentId,
    required String teacherId,
    required String attendance,
    String? performance,
    String? summary,
    String? homework,
    String? encouragementMessage,
    DateTime? sessionEnteredAt,
    DateTime? sessionEndedAt,
    required bool teacherLate,
    required int lateDurationMinutes,
  }) async {
    final now = DateTime.now();

    final document = await databases.createDocument(
      databaseId: AppConfig.appwriteDatabaseId,
      collectionId: AppConfig.sessionReportsCollectionId,
      documentId: ID.unique(),
      data: {
        'sessionId': sessionId,
        'studentId': studentId,
        'teacherId': teacherId,
        'attendance': attendance,
        if (performance != null) 'performance': performance,
        if (summary != null) 'summary': summary,
        if (homework != null) 'homework': homework,
        if (encouragementMessage != null) 'encouragementMessage': encouragementMessage,
        if (sessionEnteredAt != null) 'sessionEnteredAt': sessionEnteredAt.toIso8601String(),
        if (sessionEndedAt != null) 'sessionEndedAt': sessionEndedAt.toIso8601String(),
        'teacherLate': teacherLate,
        'lateDurationMinutes': lateDurationMinutes,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      },
      permissions: [], // Explicitly use collection-level permissions only
    );

    return document.data;
  }

  /// Get all reports for a student
  Future<List<Map<String, dynamic>>> getReportsByStudent(String studentId) async {
    final documents = await databases.listDocuments(
      databaseId: AppConfig.appwriteDatabaseId,
      collectionId: AppConfig.sessionReportsCollectionId,
      queries: [
        Query.equal('studentId', studentId),
        Query.orderDesc('createdAt'),
        Query.limit(100),
      ],
    );

    return documents.documents.map((doc) => doc.data).toList();
  }

  /// Get all reports for a teacher
  Future<List<Map<String, dynamic>>> getReportsByTeacher(String teacherId) async {
    final documents = await databases.listDocuments(
      databaseId: AppConfig.appwriteDatabaseId,
      collectionId: AppConfig.sessionReportsCollectionId,
      queries: [
        Query.equal('teacherId', teacherId),
        Query.orderDesc('createdAt'),
        Query.limit(100),
      ],
    );

    return documents.documents.map((doc) => doc.data).toList();
  }

  /// Get report by session ID
  Future<Map<String, dynamic>?> getReportBySession(String sessionId) async {
    final documents = await databases.listDocuments(
      databaseId: AppConfig.appwriteDatabaseId,
      collectionId: AppConfig.sessionReportsCollectionId,
      queries: [
        Query.equal('sessionId', sessionId),
        Query.limit(1),
      ],
    );

    if (documents.documents.isEmpty) return null;
    return documents.documents.first.data;
  }

  /// Get all reports (admin)
  Future<List<Map<String, dynamic>>> getAllReports() async {
    final documents = await databases.listDocuments(
      databaseId: AppConfig.appwriteDatabaseId,
      collectionId: AppConfig.sessionReportsCollectionId,
      queries: [
        Query.orderDesc('createdAt'),
        Query.limit(100),
      ],
    );

    return documents.documents.map((doc) => doc.data).toList();
  }

  /// Get reports with late teachers (admin)
  Future<List<Map<String, dynamic>>> getLateTeacherReports() async {
    final documents = await databases.listDocuments(
      databaseId: AppConfig.appwriteDatabaseId,
      collectionId: AppConfig.sessionReportsCollectionId,
      queries: [
        Query.equal('teacherLate', true),
        Query.orderDesc('createdAt'),
        Query.limit(100),
      ],
    );

    return documents.documents.map((doc) => doc.data).toList();
  }

  /// Update a session report
  Future<Map<String, dynamic>> updateReport({
    required String reportId,
    String? attendance,
    String? performance,
    String? summary,
    String? homework,
    String? encouragementMessage,
  }) async {
    final document = await databases.updateDocument(
      databaseId: AppConfig.appwriteDatabaseId,
      collectionId: AppConfig.sessionReportsCollectionId,
      documentId: reportId,
      data: {
        if (attendance != null) 'attendance': attendance,
        if (performance != null) 'performance': performance,
        if (summary != null) 'summary': summary,
        if (homework != null) 'homework': homework,
        if (encouragementMessage != null) 'encouragementMessage': encouragementMessage,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );

    return document.data;
  }

  /// Delete a report (admin only)
  Future<void> deleteReport(String reportId) async {
    await databases.deleteDocument(
      databaseId: AppConfig.appwriteDatabaseId,
      collectionId: AppConfig.sessionReportsCollectionId,
      documentId: reportId,
    );
  }
}
