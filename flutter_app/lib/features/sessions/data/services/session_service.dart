import 'package:appwrite/appwrite.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';

/// Session Service - Handles all Appwrite operations for class sessions
class SessionService {
  final Databases databases;

  SessionService({required this.databases});

  /// Create a new class session
  Future<Map<String, dynamic>> createSession({
    required String teacherId,
    required String studentId,
    required String courseId,
    String? planId,
    required DateTime scheduledDate,
    required String scheduledTime,
    required int duration,
    required double salaryAmount,
    String? notes,
    String? meetingLink,
    String? createdBy,
  }) async {
    try {
      final response = await databases.createDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        documentId: ID.unique(),
        data: {
          'teacherId': teacherId,
          'studentId': studentId,
          'courseId': courseId,
          'planId': planId,
          'scheduledDate': scheduledDate.toIso8601String(),
          'scheduledTime': scheduledTime,
          'duration': duration,
          'status': AppConfig.sessionStatusScheduled,
          'salaryAmount': salaryAmount,
          'notes': notes,
          'meetingLink': meetingLink,
          'createdBy': createdBy,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      return response.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to create session: ${e.message}');
    }
  }

  /// Get session by ID
  Future<Map<String, dynamic>> getSession(String sessionId) async {
    try {
      final response = await databases.getDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        documentId: sessionId,
      );

      return response.data;
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        throw Exception('Session not found');
      }
      throw Exception('Failed to fetch session: ${e.message}');
    }
  }

  /// Get all sessions with optional filters
  /// [isAdminRequest] must be true for requests without teacherId filter
  Future<List<Map<String, dynamic>>> getAllSessions({
    String? teacherId,
    String? studentId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
    bool isAdminRequest = false,
  }) async {
    // SECURITY: Enforce teacherId filter for non-admin requests
    if (!isAdminRequest && teacherId == null) {
      throw Exception('teacherId is required for non-admin requests');
    }

    try {
      final queries = <String>[];

      if (teacherId != null) {
        queries.add(Query.equal('teacherId', teacherId));
      }
      if (studentId != null) {
        queries.add(Query.equal('studentId', studentId));
      }
      if (status != null) {
        queries.add(Query.equal('status', status));
      }
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('scheduledDate', startDate.toIso8601String()));
      }
      if (endDate != null) {
        queries.add(Query.lessThanEqual('scheduledDate', endDate.toIso8601String()));
      }

      queries.add(Query.orderDesc('scheduledDate'));
      queries.add(Query.limit(limit));

      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: queries,
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch sessions: ${e.message}');
    }
  }

  /// Update a session
  Future<Map<String, dynamic>> updateSession({
    required String sessionId,
    String? teacherId,
    String? studentId,
    String? courseId,
    String? planId,
    DateTime? scheduledDate,
    String? scheduledTime,
    int? duration,
    String? status,
    String? attendanceStatus,
    double? salaryAmount,
    String? notes,
    String? meetingLink,
    DateTime? completedAt,
  }) async {
    try {
      final data = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (teacherId != null) data['teacherId'] = teacherId;
      if (studentId != null) data['studentId'] = studentId;
      if (courseId != null) data['courseId'] = courseId;
      if (planId != null) data['planId'] = planId;
      if (scheduledDate != null) data['scheduledDate'] = scheduledDate.toIso8601String();
      if (scheduledTime != null) data['scheduledTime'] = scheduledTime;
      if (duration != null) data['duration'] = duration;
      if (status != null) data['status'] = status;
      if (attendanceStatus != null) data['attendanceStatus'] = attendanceStatus;
      if (salaryAmount != null) data['salaryAmount'] = salaryAmount;
      if (notes != null) data['notes'] = notes;
      if (meetingLink != null) data['meetingLink'] = meetingLink;
      if (completedAt != null) data['completedAt'] = completedAt.toIso8601String();

      final response = await databases.updateDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        documentId: sessionId,
        data: data,
      );

      return response.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to update session: ${e.message}');
    }
  }

  /// Delete a session
  Future<void> deleteSession(String sessionId) async {
    try {
      await databases.deleteDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        documentId: sessionId,
      );
    } on AppwriteException catch (e) {
      throw Exception('Failed to delete session: ${e.message}');
    }
  }

  /// Get sessions for a specific date range
  /// [isAdminRequest] must be true for requests without teacherId filter
  Future<List<Map<String, dynamic>>> getSessionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? teacherId,
    String? studentId,
    bool isAdminRequest = false,
  }) async {
    // SECURITY: Enforce teacherId filter for non-admin requests
    if (!isAdminRequest && teacherId == null) {
      throw Exception('teacherId is required for non-admin requests');
    }

    try {
      final queries = <String>[
        Query.greaterThanEqual('scheduledDate', startDate.toIso8601String()),
        Query.lessThanEqual('scheduledDate', endDate.toIso8601String()),
        Query.orderAsc('scheduledDate'),
      ];

      if (teacherId != null) {
        queries.add(Query.equal('teacherId', teacherId));
      }
      if (studentId != null) {
        queries.add(Query.equal('studentId', studentId));
      }

      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: queries,
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch sessions by date range: ${e.message}');
    }
  }

  /// Mark session as completed
  Future<Map<String, dynamic>> markSessionCompleted({
    required String sessionId,
    required String attendanceStatus,
    String? notes,
  }) async {
    try {
      final response = await databases.updateDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        documentId: sessionId,
        data: {
          'status': AppConfig.sessionStatusCompleted,
          'attendanceStatus': attendanceStatus,
          'completedAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      );

      return response.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to mark session as completed: ${e.message}');
    }
  }

  /// Cancel a session
  Future<Map<String, dynamic>> cancelSession({
    required String sessionId,
    required String cancelReason,
    required String cancelledBy,
  }) async {
    try {
      final status = cancelledBy == 'student'
          ? AppConfig.sessionStatusStudentCancel
          : AppConfig.sessionStatusTeacherCancel;

      final response = await databases.updateDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        documentId: sessionId,
        data: {
          'status': status,
          'notes': cancelReason,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      return response.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to cancel session: ${e.message}');
    }
  }

  /// Get upcoming sessions
  /// [isAdminRequest] must be true for requests without teacherId filter
  Future<List<Map<String, dynamic>>> getUpcomingSessions({
    String? teacherId,
    String? studentId,
    int limit = 50,
    bool isAdminRequest = false,
  }) async {
    // SECURITY: Enforce teacherId filter for non-admin requests
    if (!isAdminRequest && teacherId == null) {
      throw Exception('teacherId is required for non-admin requests');
    }

    try {
      final now = DateTime.now();
      final queries = <String>[
        Query.greaterThanEqual('scheduledDate', now.toIso8601String()),
        Query.equal('status', AppConfig.sessionStatusScheduled),
        Query.orderAsc('scheduledDate'),
        Query.limit(limit),
      ];

      if (teacherId != null) {
        queries.add(Query.equal('teacherId', teacherId));
      }
      if (studentId != null) {
        queries.add(Query.equal('studentId', studentId));
      }

      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.classSessionsCollectionId,
        queries: queries,
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch upcoming sessions: ${e.message}');
    }
  }
}
