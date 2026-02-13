import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/core/models/session_report_model.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/utils/time_utils.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';
import 'package:quran_gate_academy/features/sessions/domain/repositories/session_repository.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_report_cubit.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_report_state.dart';

/// Student Reports Page - View all session reports
class StudentReportsPage extends StatelessWidget {
  const StudentReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final linkedStudentId =
        authState is AuthAuthenticated ? authState.user.linkedStudentId : null;

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
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                            return _EnhancedReportCard(
                              report: filteredReports[index],
                            );
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
}

/// Enhanced Report Card Widget with Comprehensive Details
class _EnhancedReportCard extends StatefulWidget {
  final SessionReportModel report;

  const _EnhancedReportCard({required this.report});

  @override
  State<_EnhancedReportCard> createState() => _EnhancedReportCardState();
}

class _EnhancedReportCardState extends State<_EnhancedReportCard> {
  ClassSessionModel? _session;
  bool _isLoadingSession = true;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    try {
      final sessionRepo = getIt<SessionRepository>();
      final session = await sessionRepo.getSession(widget.report.sessionId);
      if (mounted) {
        setState(() {
          _session = session;
          _isLoadingSession = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSession = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Session Metadata
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.05),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateFormat.format(widget.report.createdAt),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_isLoadingSession)
                            const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else if (_session != null) ...[
                            Row(
                              children: [
                                Icon(Icons.person_outline,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  _session!.teacherName ?? 'Teacher',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    _buildAttendanceBadge(widget.report.attendance),
                  ],
                ),

                // Session Time Info
                if (_session != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTimeInfo(
                            icon: Icons.schedule,
                            label: 'Scheduled',
                            value: TimeUtils.formatTo12Hour(
                                _session!.scheduledTime),
                          ),
                        ),
                        if (widget.report.sessionEnteredAt != null) ...[
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.grey[300],
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          Expanded(
                            child: _buildTimeInfo(
                              icon: Icons.play_circle_outline,
                              label: 'Started',
                              value: timeFormat
                                  .format(widget.report.sessionEnteredAt!),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Performance Badge (if attended)
                if (widget.report.isAttended &&
                    widget.report.performance != null) ...[
                  const SizedBox(height: 12),
                  _buildPerformanceBadge(widget.report.performance!),
                ],
              ],
            ),
          ),

          // Expandable Content Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.report.isAttended) ...[
                  // Session Duration & Metrics
                  if (widget.report.sessionEnteredAt != null &&
                      widget.report.sessionEndedAt != null) ...[
                    _buildMetricsRow(),
                    const Divider(height: 24),
                  ],

                  // Summary
                  if (widget.report.summary != null &&
                      widget.report.summary!.isNotEmpty) ...[
                    _buildSectionTitle('Session Summary', Icons.description),
                    const SizedBox(height: 8),
                    Text(
                      widget.report.summary!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Homework
                  if (widget.report.homework != null &&
                      widget.report.homework!.isNotEmpty) ...[
                    _buildSectionTitle('Homework Assignment', Icons.assignment),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.task_alt,
                              size: 22, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.report.homework!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Encouragement Message
                  if (widget.report.encouragementMessage != null &&
                      widget.report.encouragementMessage!.isNotEmpty) ...[
                    _buildSectionTitle('Teacher\'s Message', Icons.favorite),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.05),
                            Colors.green.withOpacity(0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.format_quote,
                              size: 22, color: Colors.green[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.report.encouragementMessage!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                fontStyle: FontStyle.italic,
                                height: 1.6,
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
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.grey[600], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You were marked absent for this session',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Teacher Late Indicator
                if (widget.report.teacherLate) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule,
                            size: 16, color: Colors.orange[700]),
                        const SizedBox(width: 6),
                        Text(
                          'Teacher arrived ${widget.report.lateDurationMinutes} min late',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceBadge(String attendance) {
    final isAttended = attendance == AppConfig.attendanceAttended;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isAttended
            ? Colors.green.withOpacity(0.15)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAttended ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAttended ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: isAttended ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            isAttended ? 'Attended' : 'Absent',
            style: TextStyle(
              color: isAttended ? Colors.green[800] : Colors.red[800],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBadge(String performance) {
    final isExcellent = performance.toLowerCase() == 'excellent';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExcellent
              ? [Colors.amber[400]!, Colors.amber[600]!]
              : [Colors.blue[400]!, Colors.blue[600]!],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: (isExcellent ? Colors.amber : Colors.blue).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Performance: ${performance.toUpperCase()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsRow() {
    final duration = widget.report.sessionEndedAt!
        .difference(widget.report.sessionEnteredAt!);
    final durationMinutes = duration.inMinutes;
    final scheduledDuration = _session?.duration ?? 60;
    final isOvertime = durationMinutes > scheduledDuration;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            icon: Icons.timer,
            label: 'Duration',
            value: '$durationMinutes min',
            color: isOvertime ? Colors.orange : Colors.blue,
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          _buildMetricItem(
            icon: Icons.access_time,
            label: 'Scheduled',
            value: '$scheduledDuration min',
            color: Colors.grey[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
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
