import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/core/models/user_model.dart';

/// Session repository interface
abstract class SessionRepository {
  /// Create a new class session
  Future<ClassSessionModel> createSession({
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
  });

  /// Get session by ID
  Future<ClassSessionModel> getSession(String sessionId);

  /// Get all sessions with optional filters
  /// [currentUser] is required for permission checking and data filtering
  Future<List<ClassSessionModel>> getAllSessions({
    UserModel? currentUser,
    String? teacherId,
    String? studentId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  });

  /// Update a session
  Future<ClassSessionModel> updateSession({
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
  });

  /// Delete a session
  Future<void> deleteSession(String sessionId);

  /// Get sessions for a specific date range
  /// [currentUser] is required for permission checking and data filtering
  Future<List<ClassSessionModel>> getSessionsByDateRange({
    UserModel? currentUser,
    required DateTime startDate,
    required DateTime endDate,
    String? teacherId,
    String? studentId,
  });

  /// Mark session as completed
  Future<ClassSessionModel> markSessionCompleted({
    required String sessionId,
    required String attendanceStatus,
    String? notes,
  });

  /// Cancel a session
  Future<ClassSessionModel> cancelSession({
    required String sessionId,
    required String cancelReason,
    required String cancelledBy,
  });

  /// Get upcoming sessions
  /// [currentUser] is required for permission checking and data filtering
  Future<List<ClassSessionModel>> getUpcomingSessions({
    UserModel? currentUser,
    String? teacherId,
    String? studentId,
    int limit = 50,
  });
}
