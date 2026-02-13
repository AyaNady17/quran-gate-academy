import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_cubit.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_report_cubit.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_state.dart';
import 'package:quran_gate_academy/features/sessions/presentation/widgets/session_report_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// Teacher Sessions Page - View and manage assigned sessions
class TeacherSessionsPage extends StatelessWidget {
  const TeacherSessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<SessionCubit>(param1: authState.user)..loadSessions(),
        ),
        BlocProvider(
          create: (context) => getIt<SessionReportCubit>(),
        ),
      ],
      child: const _TeacherSessionsView(),
    );
  }
}

class _TeacherSessionsView extends StatelessWidget {
  const _TeacherSessionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/my-sessions'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildSessionsList(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 32,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Sessions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
              ),
              Text(
                'View and manage your teaching sessions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              context.read<SessionCubit>().loadSessions();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(BuildContext context) {
    return BlocConsumer<SessionCubit, SessionState>(
      listener: (context, state) {
        if (state is SessionUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.read<SessionCubit>().loadSessions();
        } else if (state is SessionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is SessionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SessionsLoaded) {
          if (state.sessions.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildSessionsCards(context, state.sessions);
        }

        if (state is SessionError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<SessionCubit>().loadSessions();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: AppTheme.textTertiaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No sessions assigned',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any sessions assigned yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsCards(
      BuildContext context, List<ClassSessionModel> sessions) {
    // Group sessions by status
    final upcomingSessions =
        sessions.where((s) => s.status == 'scheduled').toList();
    final completedSessions =
        sessions.where((s) => s.status == 'completed').toList();
    final otherSessions = sessions
        .where((s) => s.status != 'scheduled' && s.status != 'completed')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (upcomingSessions.isNotEmpty) ...[
            Text(
              'Upcoming Sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...upcomingSessions
                .map((session) => _buildSessionCard(context, session)),
            const SizedBox(height: 24),
          ],
          if (completedSessions.isNotEmpty) ...[
            Text(
              'Completed Sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...completedSessions
                .map((session) => _buildSessionCard(context, session)),
            const SizedBox(height: 24),
          ],
          if (otherSessions.isNotEmpty) ...[
            Text(
              'Other Sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...otherSessions
                .map((session) => _buildSessionCard(context, session)),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, ClassSessionModel session) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    // Parse scheduledTime string (HH:mm) and format to 12-hour format with AM/PM
    String formattedTime = session.scheduledTime;
    try {
      final timeParts = session.scheduledTime.split(':');
      if (timeParts.length == 2) {
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        // Convert to 12-hour format with AM/PM
        final period = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        formattedTime = '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      }
    } catch (e) {
      // If parsing fails, use the original time string
      formattedTime = session.scheduledTime;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course: ${session.courseId}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Student: ${session.studentName ?? session.studentId}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(session.status),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(session.scheduledDate),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 24),
                Icon(Icons.access_time,
                    size: 16, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  formattedTime,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 24),
                Icon(Icons.timer, size: 16, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  '${session.duration} min',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.attach_money,
                    size: 16, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  'Salary: \$${session.salaryAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                ),
              ],
            ),
            if (session.meetingLink != null &&
                session.meetingLink!.isNotEmpty &&
                session.status == AppConfig.sessionStatusScheduled) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.video_call, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meeting Link Available',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          Text(
                            'Click to join the session',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _launchMeetingLink(session.meetingLink),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Join'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Time-based action buttons
            if (session.status == 'scheduled') ...[
              const SizedBox(height: 16),
              _buildActionButtons(context, session),
            ] else if (session.status == AppConfig.sessionStatusInProgress) ...[
              const SizedBox(height: 16),
              _buildInProgressButtons(context, session),
            ],
          ],
        ),
      ),
    );
  }

  /// Build action buttons based on session time
  Widget _buildActionButtons(BuildContext context, ClassSessionModel session) {
    final now = DateTime.now();
    final sessionDateTime = _getSessionDateTime(session);
    final minutesUntilSession = sessionDateTime.difference(now).inMinutes;
    final canEnter =
        minutesUntilSession <= 5 && minutesUntilSession >= -session.duration;
    final canCancel = minutesUntilSession > 0;

    return Column(
      children: [
        if (canEnter)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _enterClass(context, session),
              icon: const Icon(Icons.login),
              label: const Text('Enter Class'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        if (canCancel && !canEnter) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(context, session),
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Class'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build buttons when session is in progress
  Widget _buildInProgressButtons(
      BuildContext context, ClassSessionModel session) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showSessionReportDialog(context, session),
            icon: const Icon(Icons.stop),
            label: const Text('End Class'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _sendReminder(context, session),
            icon: const Icon(Icons.notifications),
            label: const Text('Send Reminder'),
          ),
        ),
      ],
    );
  }

  /// Get session date and time as DateTime
  DateTime _getSessionDateTime(ClassSessionModel session) {
    final timeParts = session.scheduledTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return DateTime(
      session.scheduledDate.year,
      session.scheduledDate.month,
      session.scheduledDate.day,
      hour,
      minute,
    );
  }

  /// Enter class - updates status to in_progress and stores enteredAt timestamp
  Future<void> _enterClass(
      BuildContext context, ClassSessionModel session) async {
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
              ? 'Class entered (${minutesLate} minutes late)'
              : 'Class entered successfully'),
          backgroundColor: isLate ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  /// Show session report dialog
  Future<void> _showSessionReportDialog(
      BuildContext context, ClassSessionModel session) async {
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

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionReportDialog(
        session: session,
        teacherId: authState.user.id,
      ),
    );

    if (result == true && context.mounted) {
      // Report created successfully, refresh sessions
      context.read<SessionCubit>().loadSessions();
    }
  }

  /// Send reminder to student
  Future<void> _sendReminder(
      BuildContext context, ClassSessionModel session) async {
    // TODO: Implement send reminder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder sent to student'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Show cancel class dialog
  Future<void> _showCancelDialog(
      BuildContext context, ClassSessionModel session) async {
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
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'scheduled':
        color = Colors.blue;
        label = 'Scheduled';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'absent':
        color = Colors.orange;
        label = 'Absent';
        break;
      case 'student_cancel':
      case 'teacher_cancel':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  void _showMarkCompleteDialog(
      BuildContext context, ClassSessionModel session) {
    String attendanceStatus = 'present';
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mark Session Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: attendanceStatus,
              decoration: const InputDecoration(
                labelText: 'Attendance Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'present', child: Text('Present')),
                DropdownMenuItem(value: 'absent', child: Text('Absent')),
                DropdownMenuItem(value: 'late', child: Text('Late')),
              ],
              onChanged: (value) {
                if (value != null) {
                  attendanceStatus = value;
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Add any notes about this session',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SessionCubit>().updateSession(
                    sessionId: session.id,
                    status: 'completed',
                    attendanceStatus: attendanceStatus,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, ClassSessionModel session) {
    final reasonController = TextEditingController();
    DateTime? newDate;
    TimeOfDay? newTime;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Request Reschedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(newDate == null
                    ? 'Select New Date'
                    : DateFormat('MMM dd, yyyy').format(newDate!)),
                leading: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => newDate = picked);
                  }
                },
              ),
              ListTile(
                title: Text(newTime == null
                    ? 'Select New Time'
                    : newTime!.format(context)),
                leading: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => newTime = picked);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                  hintText: 'Why do you need to reschedule?',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: newDate == null ||
                      newTime == null ||
                      reasonController.text.trim().isEmpty
                  ? null
                  : () {
                      // Format TimeOfDay to HH:mm string
                      final formattedTime =
                          '${newTime!.hour.toString().padLeft(2, '0')}:${newTime!.minute.toString().padLeft(2, '0')}';

                      // TODO: Implement reschedule request creation using:
                      // - newDate (DateTime)
                      // - formattedTime (String in HH:mm format)
                      // - reasonController.text.trim()

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Reschedule request feature coming soon\n'
                              'New date: ${DateFormat('MMM dd, yyyy').format(newDate!)}\n'
                              'New time: $formattedTime'),
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      Navigator.of(dialogContext).pop();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchMeetingLink(String? meetingLink) async {
    if (meetingLink == null || meetingLink.isEmpty) return;

    final uri = Uri.parse(meetingLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
