import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/core/services/whatsapp_service.dart';
import 'package:quran_gate_academy/core/utils/time_utils.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_cubit.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_report_cubit.dart';
import 'package:quran_gate_academy/features/sessions/presentation/widgets/session_report_dialog.dart';
import 'package:quran_gate_academy/features/students/domain/repositories/student_repository.dart';

/// Reusable widget for displaying session action buttons
///
/// Displays context-appropriate buttons based on:
/// - Session status (scheduled, in_progress)
/// - Time until/since session start
///
/// Handles:
/// - Enter Class (5 minutes before start)
/// - Cancel Class (before start)
/// - End Class (during session)
/// - Send Reminder (during session via WhatsApp)
class SessionActionButtons extends StatelessWidget {
  final ClassSessionModel session;
  final VoidCallback onSessionUpdated;
  final bool compact;

  const SessionActionButtons({
    super.key,
    required this.session,
    required this.onSessionUpdated,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (session.status == AppConfig.sessionStatusScheduled) {
      return _buildScheduledButtons(context);
    } else if (session.status == AppConfig.sessionStatusInProgress) {
      return _buildInProgressButtons(context);
    }

    // No buttons for other statuses (completed, cancelled, etc.)
    return const SizedBox.shrink();
  }

  /// Build buttons for scheduled sessions
  Widget _buildScheduledButtons(BuildContext context) {
    final now = DateTime.now();
    final sessionDateTime = _getSessionDateTime(session);
    final minutesUntilSession = sessionDateTime.difference(now).inMinutes;

    // Enter button shows 5 minutes before until session end
    final canEnter =
        minutesUntilSession <= 5 && minutesUntilSession >= -session.duration;
    // Cancel button shows for future sessions only
    final canCancel = minutesUntilSession > 5;

    if (canEnter) {
      // Show Enter Class button with urgency styling
      final isLate = minutesUntilSession < 0;
      final isStartingSoon =
          minutesUntilSession >= 0 && minutesUntilSession <= 2;

      return compact
          ? ElevatedButton.icon(
              onPressed: () => _enterClass(context),
              icon: Icon(
                isLate ? Icons.warning_rounded : Icons.login,
                size: 16,
              ),
              label: Text(isLate
                  ? 'Late!'
                  : isStartingSoon
                      ? 'Start!'
                      : 'Enter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLate ? Colors.orange : Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            )
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _enterClass(context),
                icon: Icon(isLate ? Icons.warning_rounded : Icons.login),
                label: Text(
                  isLate
                      ? 'Enter Class (Late ${minutesUntilSession.abs()} min)'
                      : isStartingSoon
                          ? 'Start Class Now!'
                          : 'Enter Class',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLate ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                  elevation: isStartingSoon ? 4 : 2,
                ),
              ),
            );
    } else if (canCancel) {
      // Show Cancel button with countdown
      return compact
          ? OutlinedButton.icon(
              onPressed: () => _showCancelDialog(context),
              icon: const Icon(Icons.cancel, size: 16),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            )
          : SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(context),
                icon: const Icon(Icons.cancel),
                label: Text(_formatTimeUntil(minutesUntilSession)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            );
    } else {
      // Session time has passed - should not normally happen for scheduled sessions
      return compact
          ? const Chip(
              label: Text('Expired', style: TextStyle(fontSize: 12)),
              avatar: Icon(Icons.error_outline, size: 16),
              backgroundColor: Colors.red,
              labelStyle: TextStyle(color: Colors.white),
            )
          : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Session Expired',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
    }
  }

  /// Format time until session in a user-friendly way
  String _formatTimeUntil(int minutes) {
    if (minutes < 60) {
      return 'Cancel (Starts in $minutes min)';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0
          ? 'Cancel (In ${hours}h ${mins}m)'
          : 'Cancel (In $hours hours)';
    } else {
      final days = minutes ~/ 1440;
      return 'Cancel (In $days days)';
    }
  }

  /// Build buttons for in-progress sessions
  Widget _buildInProgressButtons(BuildContext context) {
    // Calculate session duration info
    final sessionDateTime = _getSessionDateTime(session);
    final now = DateTime.now();
    final minutesSinceStart = now.difference(sessionDateTime).inMinutes;
    final minutesRemaining = session.duration - minutesSinceStart;
    final isOvertime = minutesRemaining < 0;

    if (compact) {
      // Compact mode for table cells
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showSessionReportDialog(context),
            icon: const Icon(Icons.stop_circle, size: 16),
            label: const Text('End'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isOvertime ? Colors.deepOrange : Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _sendReminder(context),
            icon: const Icon(Icons.notifications_active, size: 16),
            label: const Text('Remind'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      );
    }

    // Full-width mode for cards
    return Column(
      children: [
        // Session timer indicator
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isOvertime ? Colors.orange.shade50 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isOvertime ? Icons.timer_off : Icons.timer,
                size: 16,
                color: isOvertime ? Colors.orange : Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                isOvertime
                    ? 'Overtime: ${minutesRemaining.abs()} min'
                    : 'Time left: $minutesRemaining min',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOvertime ? Colors.orange : Colors.blue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showSessionReportDialog(context),
                icon: const Icon(Icons.stop_circle),
                label: const Text('End Class'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOvertime ? Colors.deepOrange : Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _sendReminder(context),
                icon: const Icon(Icons.notifications_active),
                label: const Text('Send Reminder'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Get session date and time as DateTime
  /// Handles both 24-hour and 12-hour time formats
  DateTime _getSessionDateTime(ClassSessionModel session) {
    try {
      return TimeUtils.parseTimeString(
        session.scheduledTime,
        session.scheduledDate,
      );
    } catch (e) {
      // Fallback: if parsing fails, use current time
      // This should never happen with proper data validation
      debugPrint('Error parsing session time: ${session.scheduledTime} - $e');
      return session.scheduledDate;
    }
  }

  /// Enter class - updates status to in_progress and stores enteredAt timestamp
  Future<void> _enterClass(BuildContext context) async {
    final now = DateTime.now();
    final sessionDateTime = _getSessionDateTime(session);
    final minutesLate = now.difference(sessionDateTime).inMinutes;
    final isLate = minutesLate > 5;

    context.read<SessionCubit>().updateSession(
          sessionId: session.id,
          status: AppConfig.sessionStatusInProgress,
          enteredAt: now, // Store when teacher entered
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isLate
              ? 'Class entered ($minutesLate minutes late)'
              : 'Class entered successfully'),
          backgroundColor: isLate ? Colors.orange : Colors.green,
        ),
      );

      // Trigger parent refresh
      onSessionUpdated();
    }
  }

  /// Show session report dialog
  Future<void> _showSessionReportDialog(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication required'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Get the cubits from the parent context to provide them to the dialog
    final sessionCubit = context.read<SessionCubit>();
    final sessionReportCubit = getIt<SessionReportCubit>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: sessionCubit),
          BlocProvider<SessionReportCubit>.value(value: sessionReportCubit),
        ],
        child: SessionReportDialog(
          session: session,
          teacherId: authState.user.id,
        ),
      ),
    );

    if (result == true && context.mounted) {
      // Report created successfully, refresh parent
      onSessionUpdated();
    }
  }

  /// Send reminder to student via WhatsApp
  Future<void> _sendReminder(BuildContext context) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading student information...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Fetch student data
      final studentRepository = getIt<StudentRepository>();
      final student = await studentRepository.getStudent(session.studentId);

      if (!context.mounted) return;

      // Send WhatsApp reminder
      final whatsappService = WhatsAppService();
      final success = await whatsappService.sendReminder(
        student: student,
        session: session,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Opening WhatsApp to send reminder...'
                  : 'Failed to open WhatsApp',
            ),
            backgroundColor: success ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show cancel class dialog
  Future<void> _showCancelDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Class'),
        content: const Text('Are you sure you want to cancel this class?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<SessionCubit>().updateSession(
            sessionId: session.id,
            status: AppConfig.sessionStatusTeacherCancel,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class cancelled successfully'),
            backgroundColor: Colors.orange,
          ),
        );

        // Trigger parent refresh
        onSessionUpdated();
      }
    }
  }
}
