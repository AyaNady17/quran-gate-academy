import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/models/session_report_model.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_report_cubit.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_report_state.dart';

/// Student Reports Page - View all session reports
class StudentReportsPage extends StatelessWidget {
  const StudentReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final linkedStudentId = authState is AuthAuthenticated
        ? authState.user.linkedStudentId
        : null;

    if (linkedStudentId == null) {
      return Scaffold(
        body: Row(
          children: [
            const AppSidebar(currentRoute: '/my-reports'),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'No student account linked',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please contact administrator',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return BlocProvider(
      create: (context) =>
          getIt<SessionReportCubit>()..loadReportsByStudent(linkedStudentId),
      child: const _StudentReportsView(),
    );
  }
}

class _StudentReportsView extends StatefulWidget {
  const _StudentReportsView();

  @override
  State<_StudentReportsView> createState() => _StudentReportsViewState();
}

class _StudentReportsViewState extends State<_StudentReportsView> {
  String _attendanceFilter = 'all'; // all, attended, absent

  List<SessionReportModel> _filterReports(List<SessionReportModel> reports) {
    if (_attendanceFilter == 'all') {
      return reports;
    } else if (_attendanceFilter == 'attended') {
      return reports.where((r) => r.isAttended).toList();
    } else {
      return reports.where((r) => !r.isAttended).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/my-reports'),
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Session Reports',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'View your session history and teacher feedback',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      // Filter Buttons
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'all',
                            label: Text('All'),
                            icon: Icon(Icons.list),
                          ),
                          ButtonSegment(
                            value: 'attended',
                            label: Text('Attended'),
                            icon: Icon(Icons.check_circle),
                          ),
                          ButtonSegment(
                            value: 'absent',
                            label: Text('Absent'),
                            icon: Icon(Icons.cancel),
                          ),
                        ],
                        selected: {_attendanceFilter},
                        onSelectionChanged: (Set<String> selected) {
                          setState(() {
                            _attendanceFilter = selected.first;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Reports List
                Expanded(
                  child: BlocBuilder<SessionReportCubit, SessionReportState>(
                    builder: (context, state) {
                      if (state is SessionReportLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is SessionReportError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  final authState =
                                      context.read<AuthCubit>().state;
                                  if (authState is AuthAuthenticated &&
                                      authState.user.linkedStudentId != null) {
                                    context
                                        .read<SessionReportCubit>()
                                        .loadReportsByStudent(
                                            authState.user.linkedStudentId!);
                                  }
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is SessionReportsLoaded) {
                        final filteredReports = _filterReports(state.reports);

                        if (filteredReports.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _attendanceFilter == 'all'
                                      ? 'No session reports yet'
                                      : 'No ${_attendanceFilter} sessions found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Reports will appear here after your sessions',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            return _buildReportCard(
                                context, filteredReports[index]);
                          },
                        );
                      }

                      return const Center(
                        child: Text('No reports available'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, SessionReportModel report) {
    final dateFormat = DateFormat('EEEE, MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(report.createdAt),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (report.sessionEnteredAt != null)
                        Text(
                          'Session: ${timeFormat.format(report.sessionEnteredAt!)} - ${timeFormat.format(report.sessionEndedAt ?? report.sessionEnteredAt!)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                _buildAttendanceBadge(report.attendance),
              ],
            ),

            const Divider(height: 24),

            if (report.isAttended) ...[
              // Performance
              if (report.performance != null) ...[
                _buildInfoRow(
                  icon: Icons.star,
                  iconColor: Colors.amber,
                  label: 'Performance',
                  value: report.performance!.toUpperCase(),
                ),
                const SizedBox(height: 16),
              ],

              // Summary
              if (report.summary != null && report.summary!.isNotEmpty) ...[
                _buildSectionTitle('Session Summary'),
                const SizedBox(height: 8),
                Text(
                  report.summary!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Homework
              if (report.homework != null && report.homework!.isNotEmpty) ...[
                _buildSectionTitle('Homework'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.assignment, size: 20, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          report.homework!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Encouragement Message
              if (report.encouragementMessage != null &&
                  report.encouragementMessage!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.favorite, size: 20, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          report.encouragementMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              // Absent Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You were marked absent for this session',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Teacher Late Indicator
            if (report.teacherLate) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Teacher was ${report.lateDurationMinutes} minutes late',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceBadge(String attendance) {
    final isAttended = attendance == AppConfig.attendanceAttended;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isAttended
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAttended ? Colors.green : Colors.red,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAttended ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isAttended ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            isAttended ? 'Attended' : 'Absent',
            style: TextStyle(
              color: isAttended ? Colors.green : Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
