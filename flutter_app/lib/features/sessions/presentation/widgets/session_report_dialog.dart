import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_report_cubit.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_report_state.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_cubit.dart';

/// Dialog for creating session report when ending a class
class SessionReportDialog extends StatefulWidget {
  final ClassSessionModel session;
  final String teacherId;

  const SessionReportDialog({
    Key? key,
    required this.session,
    required this.teacherId,
  }) : super(key: key);

  @override
  State<SessionReportDialog> createState() => _SessionReportDialogState();
}

class _SessionReportDialogState extends State<SessionReportDialog> {
  final _formKey = GlobalKey<FormState>();

  String _attendance = AppConfig.attendanceAttended;
  String? _performance;
  final _summaryController = TextEditingController();
  final _homeworkController = TextEditingController();
  final _encouragementController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _summaryController.dispose();
    _homeworkController.dispose();
    _encouragementController.dispose();
    super.dispose();
  }

  bool get _isAttended => _attendance == AppConfig.attendanceAttended;

  String? _validateRequired(String? value, String fieldName) {
    if (_isAttended && (value == null || value.trim().isEmpty)) {
      return '$fieldName is required when student attended';
    }
    return null;
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isAttended && _performance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select performance level'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final now = DateTime.now();
    final sessionDateTime = _getSessionDateTime(widget.session);
    final enteredAt = widget.session.enteredAt ?? sessionDateTime;
    final minutesLate = enteredAt.difference(sessionDateTime).inMinutes;
    final teacherLate = minutesLate > 5;

    try {
      await context.read<SessionReportCubit>().createReport(
        sessionId: widget.session.id,
        studentId: widget.session.studentId,
        teacherId: widget.teacherId,
        attendance: _attendance,
        performance: _isAttended ? _performance : null,
        summary: _isAttended ? _summaryController.text.trim() : null,
        homework: _isAttended ? _homeworkController.text.trim() : null,
        encouragementMessage: _isAttended ? _encouragementController.text.trim() : null,
        sessionEnteredAt: enteredAt,
        sessionEndedAt: now,
        teacherLate: teacherLate,
        lateDurationMinutes: teacherLate ? minutesLate : 0,
      );

      // Update session status to completed
      if (mounted) {
        await context.read<SessionCubit>().updateSession(
          sessionId: widget.session.id,
          status: AppConfig.sessionStatusCompleted,
          completedAt: now,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session report created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create report: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionReportCubit, SessionReportState>(
      listener: (context, state) {
        if (state is SessionReportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'End Class & Create Report',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Student: ${widget.session.studentName ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Attendance Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Attendance *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.check_circle_outline),
                    ),
                    value: _attendance,
                    items: const [
                      DropdownMenuItem(
                        value: 'attended',
                        child: Text('Attended'),
                      ),
                      DropdownMenuItem(
                        value: 'absent',
                        child: Text('Absent'),
                      ),
                    ],
                    onChanged: _isSubmitting ? null : (value) {
                      setState(() {
                        _attendance = value!;
                        if (!_isAttended) {
                          _performance = null;
                          _summaryController.clear();
                          _homeworkController.clear();
                          _encouragementController.clear();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Show additional fields only if attended
                  if (_isAttended) ...[
                    // Performance Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Performance *',
                        hintText: 'Select performance level',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.star_outline),
                      ),
                      value: _performance,
                      items: const [
                        DropdownMenuItem(
                          value: 'good',
                          child: Text('Good'),
                        ),
                        DropdownMenuItem(
                          value: 'excellent',
                          child: Text('Excellent'),
                        ),
                      ],
                      onChanged: _isSubmitting ? null : (value) {
                        setState(() => _performance = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Summary
                    TextFormField(
                      controller: _summaryController,
                      decoration: const InputDecoration(
                        labelText: 'Session Summary *',
                        hintText: 'What was covered in this session?',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      maxLines: 3,
                      enabled: !_isSubmitting,
                      validator: (value) => _validateRequired(value, 'Summary'),
                    ),
                    const SizedBox(height: 16),

                    // Homework
                    TextFormField(
                      controller: _homeworkController,
                      decoration: const InputDecoration(
                        labelText: 'Homework *',
                        hintText: 'Assignments for the student',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.assignment_outlined),
                      ),
                      maxLines: 2,
                      enabled: !_isSubmitting,
                      validator: (value) => _validateRequired(value, 'Homework'),
                    ),
                    const SizedBox(height: 16),

                    // Encouragement Message
                    TextFormField(
                      controller: _encouragementController,
                      decoration: const InputDecoration(
                        labelText: 'Encouragement Message *',
                        hintText: 'Positive message for the student',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.favorite_outline),
                      ),
                      maxLines: 2,
                      enabled: !_isSubmitting,
                      validator: (value) => _validateRequired(value, 'Encouragement message'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '* All fields are required when student attended',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      'No additional information required for absent students',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'End Class & Submit Report',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
