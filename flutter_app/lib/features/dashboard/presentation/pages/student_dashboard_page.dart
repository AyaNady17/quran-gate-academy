import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/core/widgets/stat_card.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/student_dashboard_cubit.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/student_dashboard_state.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_report_cubit.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_report_state.dart';
import 'package:url_launcher/url_launcher.dart';

/// Student Dashboard Page - Shows personal statistics and sessions
class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final linkedStudentId = authState is AuthAuthenticated
        ? authState.user.linkedStudentId
        : null;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = getIt<StudentDashboardCubit>();
            if (linkedStudentId != null) {
              cubit.loadDashboard(studentId: linkedStudentId);
            }
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) {
            final cubit = getIt<SessionReportCubit>();
            if (linkedStudentId != null) {
              cubit.loadReportsByStudent(linkedStudentId);
            }
            return cubit;
          },
        ),
      ],
      child: const _StudentDashboardContent(),
    );
  }
}

class _StudentDashboardContent extends StatefulWidget {
  const _StudentDashboardContent();

  @override
  State<_StudentDashboardContent> createState() =>
      _StudentDashboardContentState();
}

class _StudentDashboardContentState extends State<_StudentDashboardContent> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final initialDateRange = _startDate != null && _endDate != null
        ? DateTimeRange(start: _startDate!, end: _endDate!)
        : null;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialDateRange,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _dateController.text =
            '${DateFormat('MM/dd/yyyy').format(_startDate!)} - ${DateFormat('MM/dd/yyyy').format(_endDate!)}';
      });
    }
  }

  void _search(BuildContext context) {
    if (_startDate == null) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated && authState.user.linkedStudentId != null) {
      context.read<StudentDashboardCubit>().searchSessionsByDate(
            studentId: authState.user.linkedStudentId!,
            startDate: _startDate!,
            endDate: _endDate ?? _startDate!,
          );
    }
  }

  void _refresh(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated && authState.user.linkedStudentId != null) {
      context
          .read<StudentDashboardCubit>()
          .refreshDashboard(studentId: authState.user.linkedStudentId!);
    }
  }

  Future<void> _launchMeetingLink(String? meetingLink) async {
    if (meetingLink == null || meetingLink.isEmpty) return;

    final uri = Uri.parse(meetingLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open meeting link: $meetingLink')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/'),
          Expanded(
            child: BlocBuilder<StudentDashboardCubit, StudentDashboardState>(
              builder: (context, state) {
                if (state is StudentDashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is StudentDashboardError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message,
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _refresh(context),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is StudentDashboardLoaded) {
                  return _buildDashboard(context, state);
                }

                return const Center(child: Text('Welcome to your dashboard!'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(
      BuildContext context, StudentDashboardLoaded state) {
    return RefreshIndicator(
      onRefresh: () async => _refresh(context),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Learning Dashboard',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your progress and upcoming sessions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _refresh(context),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Statistics Cards
            _buildStatsGrid(state),
            const SizedBox(height: 32),

            // Quick Actions
            _buildQuickActions(context),
            const SizedBox(height: 32),

            // Today's Sessions
            _buildTodaySessions(context, state),
            const SizedBox(height: 32),

            // Upcoming Sessions
            _buildUpcomingSessions(context, state),
            const SizedBox(height: 32),

            // Recent Session Reports
            _buildRecentReports(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(StudentDashboardLoaded state) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2,
      children: [
        StatCard(
          title: 'Total Sessions',
          value: state.stats.totalSessions.toString(),
          icon: Icons.event,
          color: Colors.blue,
        ),
        StatCard(
          title: 'Completed',
          value:
              '${state.stats.completedSessions}/${state.stats.totalSessions}',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        StatCard(
          title: 'Attendance',
          value: '${state.stats.attendancePercentage.toStringAsFixed(1)}%',
          icon: Icons.timeline,
          color: Colors.orange,
        ),
        StatCard(
          title: 'Hours Learned',
          value: state.stats.totalHoursLearned.toStringAsFixed(1),
          icon: Icons.schedule,
          color: Colors.purple,
        ),
        StatCard(
          title: 'Upcoming',
          value: state.stats.upcomingSessions.toString(),
          icon: Icons.upcoming,
          color: Colors.teal,
        ),
        StatCard(
          title: 'Today',
          value: state.stats.todaySessionsCount.toString(),
          icon: Icons.today,
          color: Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionButton(
              context,
              icon: Icons.event_note,
              label: 'My Sessions',
              onTap: () => context.go('/my-sessions'),
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.library_books,
              label: 'Learning Materials',
              onTap: () => context.go('/learning-materials'),
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.person,
              label: 'My Profile',
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySessions(
      BuildContext context, StudentDashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Sessions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state.todaySessions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No sessions scheduled for today',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...state.todaySessions.map((session) => _buildSessionCard(
                    context,
                    session,
                    showMeetingLink: true,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSessions(
      BuildContext context, StudentDashboardLoaded state) {
    final upcoming = state.upcomingSessions.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Sessions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (upcoming.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No upcoming sessions',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...upcoming.map((session) => _buildSessionCard(context, session)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReports(BuildContext context) {
    return BlocBuilder<SessionReportCubit, SessionReportState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Session Reports',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (state is SessionReportsLoaded && state.reports.isNotEmpty)
                      TextButton(
                        onPressed: () => context.go('/my-reports'),
                        child: const Text('View All'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state is SessionReportLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state is SessionReportError)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                else if (state is SessionReportsLoaded)
                  state.reports.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No session reports yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : Column(
                          children: state.reports
                              .take(5)
                              .map((report) => _buildReportCard(context, report))
                              .toList(),
                        )
                else
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No session reports yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportCard(BuildContext context, report) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(report.createdAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                _buildAttendanceBadge(report.attendance),
              ],
            ),
            const SizedBox(height: 8),
            if (report.isAttended) ...[
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    'Performance: ${report.performance ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (report.summary != null && report.summary!.isNotEmpty) ...[
                Text(
                  'Summary:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.summary!.length > 100
                      ? '${report.summary!.substring(0, 100)}...'
                      : report.summary!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ] else
              Text(
                'Student was absent',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceBadge(String attendance) {
    final isAttended = attendance == AppConfig.attendanceAttended;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isAttended ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAttended ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Text(
        isAttended ? 'Attended' : 'Absent',
        style: TextStyle(
          color: isAttended ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    ClassSessionModel session, {
    bool showMeetingLink = false,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    Color statusColor;
    switch (session.status) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'scheduled':
        statusColor = Colors.blue;
        break;
      case 'absent':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            session.status == 'completed'
                ? Icons.check_circle
                : Icons.event,
            color: statusColor,
          ),
        ),
        title: Text(
          session.teacherName ?? 'Teacher',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${dateFormat.format(session.scheduledDate)} at ${session.scheduledTime}',
            ),
            Text('Duration: ${session.duration} minutes'),
            if (session.notes != null &&
                session.notes!.isNotEmpty &&
                session.status == AppConfig.sessionStatusCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Notes: ${session.notes}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(
                session.status.toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: statusColor.withOpacity(0.2),
              labelStyle: TextStyle(color: statusColor),
            ),
            if (showMeetingLink &&
                session.meetingLink != null &&
                session.meetingLink!.isNotEmpty &&
                session.status == AppConfig.sessionStatusScheduled)
              IconButton(
                icon: const Icon(Icons.video_call, color: Colors.blue),
                onPressed: () => _launchMeetingLink(session.meetingLink),
                tooltip: 'Join Meeting',
              ),
          ],
        ),
      ),
    );
  }
}
