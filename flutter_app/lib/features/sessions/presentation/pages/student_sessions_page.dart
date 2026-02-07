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
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/student_dashboard_cubit.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/student_dashboard_state.dart';
import 'package:url_launcher/url_launcher.dart';

/// Student Sessions Page - Shows all student sessions
class StudentSessionsPage extends StatelessWidget {
  const StudentSessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final studentId = authState is AuthAuthenticated
        ? authState.user.linkedStudentId
        : null;

    if (studentId == null) {
      return Scaffold(
        body: Row(
          children: [
            const AppSidebar(currentRoute: '/my-sessions'),
            const Expanded(
              child: Center(
                child: Text('No student account linked'),
              ),
            ),
          ],
        ),
      );
    }

    return BlocProvider(
      create: (context) => getIt<StudentDashboardCubit>()..loadDashboard(studentId: studentId),
      child: const _StudentSessionsContent(),
    );
  }
}

class _StudentSessionsContent extends StatefulWidget {
  const _StudentSessionsContent();

  @override
  State<_StudentSessionsContent> createState() =>
      _StudentSessionsContentState();
}

class _StudentSessionsContentState extends State<_StudentSessionsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchMeetingLink(String? meetingLink) async {
    if (meetingLink == null || meetingLink.isEmpty) return;

    final uri = Uri.parse(meetingLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
                _buildTabs(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUpcomingSessions(context),
                      _buildCompletedSessions(context),
                      _buildAllSessions(context),
                    ],
                  ),
                ),
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
            Icons.event_note,
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
                'View all your learning sessions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textSecondaryColor,
        indicatorColor: AppTheme.primaryColor,
        tabs: const [
          Tab(text: 'Upcoming'),
          Tab(text: 'Completed'),
          Tab(text: 'All Sessions'),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessions(BuildContext context) {
    return BlocBuilder<StudentDashboardCubit, StudentDashboardState>(
      builder: (context, state) {
        if (state is StudentDashboardLoaded) {
          final upcoming = state.upcomingSessions;
          if (upcoming.isEmpty) {
            return const Center(child: Text('No upcoming sessions'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: upcoming.length,
            itemBuilder: (context, index) {
              return _buildSessionCard(context, upcoming[index], showMeetingLink: true);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCompletedSessions(BuildContext context) {
    return const Center(child: Text('Completed sessions - coming soon'));
  }

  Widget _buildAllSessions(BuildContext context) {
    return BlocBuilder<StudentDashboardCubit, StudentDashboardState>(
      builder: (context, state) {
        if (state is StudentDashboardLoaded) {
          final all = [...state.todaySessions, ...state.upcomingSessions];
          if (all.isEmpty) {
            return const Center(child: Text('No sessions found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: all.length,
            itemBuilder: (context, index) {
              return _buildSessionCard(context, all[index], showMeetingLink: true);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    ClassSessionModel session, {
    bool showMeetingLink = false,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy');

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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            session.status == 'completed' ? Icons.check_circle : Icons.event,
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
