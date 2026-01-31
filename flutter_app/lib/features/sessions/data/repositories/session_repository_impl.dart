import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/core/models/user_model.dart';
import 'package:quran_gate_academy/core/services/permission_service.dart';
import 'package:quran_gate_academy/features/sessions/data/services/session_service.dart';
import 'package:quran_gate_academy/features/sessions/domain/repositories/session_repository.dart';

/// Session repository implementation
class SessionRepositoryImpl implements SessionRepository {
  final SessionService sessionService;

  SessionRepositoryImpl({required this.sessionService});

  @override
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
  }) async {
    try {
      final sessionData = await sessionService.createSession(
        teacherId: teacherId,
        studentId: studentId,
        courseId: courseId,
        planId: planId,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        duration: duration,
        salaryAmount: salaryAmount,
        notes: notes,
        meetingLink: meetingLink,
        createdBy: createdBy,
      );

      return ClassSessionModel.fromJson(sessionData);
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  @override
  Future<ClassSessionModel> getSession(String sessionId) async {
    try {
      final sessionData = await sessionService.getSession(sessionId);
      return ClassSessionModel.fromJson(sessionData);
    } catch (e) {
      throw Exception('Failed to get session: $e');
    }
  }

  @override
  Future<List<ClassSessionModel>> getAllSessions({
    UserModel? currentUser,
    String? teacherId,
    String? studentId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      // Check if user is admin
      final isAdmin = currentUser != null && PermissionService.isAdmin(currentUser);

      // For teachers, force their own teacherId
      final effectiveTeacherId = isAdmin ? teacherId : currentUser?.userId;

      final sessionsData = await sessionService.getAllSessions(
        teacherId: effectiveTeacherId,
        studentId: studentId,
        status: status,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        isAdminRequest: isAdmin,
      );

      return sessionsData.map((data) => ClassSessionModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get all sessions: $e');
    }
  }

  @override
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
  }) async {
    try {
      final sessionData = await sessionService.updateSession(
        sessionId: sessionId,
        teacherId: teacherId,
        studentId: studentId,
        courseId: courseId,
        planId: planId,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        duration: duration,
        status: status,
        attendanceStatus: attendanceStatus,
        salaryAmount: salaryAmount,
        notes: notes,
        meetingLink: meetingLink,
        completedAt: completedAt,
      );

      return ClassSessionModel.fromJson(sessionData);
    } catch (e) {
      throw Exception('Failed to update session: $e');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      await sessionService.deleteSession(sessionId);
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  @override
  Future<List<ClassSessionModel>> getSessionsByDateRange({
    UserModel? currentUser,
    required DateTime startDate,
    required DateTime endDate,
    String? teacherId,
    String? studentId,
  }) async {
    try {
      // Check if user is admin
      final isAdmin = currentUser != null && PermissionService.isAdmin(currentUser);

      // For teachers, force their own teacherId
      final effectiveTeacherId = isAdmin ? teacherId : currentUser?.userId;

      final sessionsData = await sessionService.getSessionsByDateRange(
        startDate: startDate,
        endDate: endDate,
        teacherId: effectiveTeacherId,
        studentId: studentId,
        isAdminRequest: isAdmin,
      );

      return sessionsData.map((data) => ClassSessionModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get sessions by date range: $e');
    }
  }

  @override
  Future<ClassSessionModel> markSessionCompleted({
    required String sessionId,
    required String attendanceStatus,
    String? notes,
  }) async {
    try {
      final sessionData = await sessionService.markSessionCompleted(
        sessionId: sessionId,
        attendanceStatus: attendanceStatus,
        notes: notes,
      );

      return ClassSessionModel.fromJson(sessionData);
    } catch (e) {
      throw Exception('Failed to mark session as completed: $e');
    }
  }

  @override
  Future<ClassSessionModel> cancelSession({
    required String sessionId,
    required String cancelReason,
    required String cancelledBy,
  }) async {
    try {
      final sessionData = await sessionService.cancelSession(
        sessionId: sessionId,
        cancelReason: cancelReason,
        cancelledBy: cancelledBy,
      );

      return ClassSessionModel.fromJson(sessionData);
    } catch (e) {
      throw Exception('Failed to cancel session: $e');
    }
  }

  @override
  Future<List<ClassSessionModel>> getUpcomingSessions({
    UserModel? currentUser,
    String? teacherId,
    String? studentId,
    int limit = 50,
  }) async {
    try {
      // Check if user is admin
      final isAdmin = currentUser != null && PermissionService.isAdmin(currentUser);

      // For teachers, force their own teacherId
      final effectiveTeacherId = isAdmin ? teacherId : currentUser?.userId;

      final sessionsData = await sessionService.getUpcomingSessions(
        teacherId: effectiveTeacherId,
        studentId: studentId,
        limit: limit,
        isAdminRequest: isAdmin,
      );

      return sessionsData.map((data) => ClassSessionModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming sessions: $e');
    }
  }
}
