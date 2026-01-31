import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/core/models/user_model.dart';
import 'package:quran_gate_academy/features/sessions/domain/repositories/session_repository.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_state.dart';

/// Session Cubit - Manages session state and business logic
class SessionCubit extends Cubit<SessionState> {
  final SessionRepository sessionRepository;
  final UserModel currentUser;

  SessionCubit({
    required this.sessionRepository,
    required this.currentUser,
  }) : super(SessionInitial());

  /// Load all sessions with optional filters
  Future<void> loadSessions({
    String? teacherId,
    String? studentId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(SessionLoading());
    try {
      final sessions = await sessionRepository.getAllSessions(
        currentUser: currentUser,
        teacherId: teacherId,
        studentId: studentId,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      emit(SessionsLoaded(sessions));
    } catch (e) {
      emit(SessionError('Failed to load sessions: ${e.toString()}'));
    }
  }

  /// Load a single session
  Future<void> loadSession(String sessionId) async {
    emit(SessionLoading());
    try {
      final session = await sessionRepository.getSession(sessionId);
      emit(SessionLoaded(session));
    } catch (e) {
      emit(SessionError('Failed to load session: ${e.toString()}'));
    }
  }

  /// Create a new session
  Future<void> createSession({
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
    emit(SessionLoading());
    try {
      final session = await sessionRepository.createSession(
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
      emit(SessionCreated(session));
    } catch (e) {
      emit(SessionError('Failed to create session: ${e.toString()}'));
    }
  }

  /// Update an existing session
  Future<void> updateSession({
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
    emit(SessionLoading());
    try {
      final session = await sessionRepository.updateSession(
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
      emit(SessionUpdated(session));
    } catch (e) {
      emit(SessionError('Failed to update session: ${e.toString()}'));
    }
  }

  /// Delete a session
  Future<void> deleteSession(String sessionId) async {
    emit(SessionLoading());
    try {
      await sessionRepository.deleteSession(sessionId);
      emit(SessionDeleted());
    } catch (e) {
      emit(SessionError('Failed to delete session: ${e.toString()}'));
    }
  }

  /// Mark session as completed
  Future<void> markSessionCompleted({
    required String sessionId,
    required String attendanceStatus,
    String? notes,
  }) async {
    emit(SessionLoading());
    try {
      final session = await sessionRepository.markSessionCompleted(
        sessionId: sessionId,
        attendanceStatus: attendanceStatus,
        notes: notes,
      );
      emit(SessionUpdated(session));
    } catch (e) {
      emit(SessionError('Failed to mark session as completed: ${e.toString()}'));
    }
  }

  /// Cancel a session
  Future<void> cancelSession({
    required String sessionId,
    required String cancelReason,
    required String cancelledBy,
  }) async {
    emit(SessionLoading());
    try {
      final session = await sessionRepository.cancelSession(
        sessionId: sessionId,
        cancelReason: cancelReason,
        cancelledBy: cancelledBy,
      );
      emit(SessionUpdated(session));
    } catch (e) {
      emit(SessionError('Failed to cancel session: ${e.toString()}'));
    }
  }

  /// Load upcoming sessions
  Future<void> loadUpcomingSessions({
    String? teacherId,
    String? studentId,
  }) async {
    emit(SessionLoading());
    try {
      final sessions = await sessionRepository.getUpcomingSessions(
        currentUser: currentUser,
        teacherId: teacherId,
        studentId: studentId,
      );
      emit(SessionsLoaded(sessions));
    } catch (e) {
      emit(SessionError('Failed to load upcoming sessions: ${e.toString()}'));
    }
  }

  /// Refresh sessions list
  Future<void> refreshSessions({
    String? teacherId,
    String? studentId,
    String? status,
  }) async {
    await loadSessions(
      teacherId: teacherId,
      studentId: studentId,
      status: status,
    );
  }
}
