import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/core/router/app_router.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/student_dashboard_cubit.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/student_dashboard_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

/// Student dashboard page showing sessions and statistics
class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = GetIt.I<StudentDashboardCubit>();
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthAuthenticated &&
            authState.user.linkedStudentId != null) {
          cubit.loadDashboard(studentId: authState.user.linkedStudentId!);
        }
        return cubit;
      },
      child: const _StudentDashboardContent(),
    );
  }
}

class _StudentDashboardContent extends StatelessWidget {
  const _StudentDashboardContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: AppRouter.dashboardRoute),
          Expanded(
            child: BlocConsumer<StudentDashboardCubit, StudentDashboardState>(
              listener: (context, state) {
                if (state is StudentDashboardError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is StudentDashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is StudentDashboardLoaded) {
                  return RefreshIndicator(
                    onRefresh: () => _refreshDashboard(context),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 32),
                          _buildStatsGrid(state),
                          const SizedBox(height: 32),
                          _buildTodaySessions(context, state),
                          const SizedBox(height: 32),
                          _buildUpcomingSessions(context, state),
                          const SizedBox(height: 32),
                          _buildQuickActions(context),
                        ],
                      ),
                    ),
                  );
                }

                if (state is StudentDashboardError) {
                  return _buildErrorState(context, state.message);
                }

                return const Center(child: Text('Welcome to your dashboard!'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final userName = authState is AuthAuthenticated ? authState.user.fullName : 'Student';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $userName!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Here\'s your learning progress',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(StudentDashboardLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 5 :
                               constraints.maxWidth > 800 ? 3 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              context,
              'Total Sessions',
              state.stats.totalSessions.toString(),
              Icons.event,
              Colors.blue,
            ),
            _buildStatCard(
              context,
              'Completed',
              state.stats.completedSessions.toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              context,
              'Upcoming',
              state.stats.upcomingSessions.toString(),
              Icons.schedule,
              Colors.orange,
            ),
            _buildStatCard(
              context,
              'Hours Learned',
              state.stats.totalHoursLearned.toStringAsFixed(1),
              Icons.access_time,
              Colors.purple,
            ),
            _buildStatCard(
              context,
              'Attendance',
              '${state.stats.attendancePercentage.toStringAsFixed(0)}%',
              Icons.trending_up,
              Colors.teal,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySessions(BuildContext context, StudentDashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Sessions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (state.todaySessions.isEmpty)
          _buildEmptyState('No sessions scheduled for today')
        else
          ...state.todaySessions.map((session) => _buildSessionCard(context, session)),
      ],
    );
  }

  Widget _buildUpcomingSessions(BuildContext context, StudentDashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => context.go('/my-sessions'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.upcomingSessions.isEmpty)
          _buildEmptyState('No upcoming sessions')
        else
          ...state.upcomingSessions.map((session) => _buildSessionCard(context, session)),
      ],
    );
  }

  Widget _buildSessionCard(BuildContext context, ClassSessionModel session) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isToday = _isToday(session.scheduledDate);
    final isUpcoming = session.scheduledDate.isAfter(DateTime.now());
    final showMeetingLink = isToday || isUpcoming;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
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
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(session.scheduledDate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      session.scheduledTime,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Teacher: ${session.teacherName ?? "Unknown"}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.duration} minutes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                if (session.notes != null && session.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    session.notes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (showMeetingLink && session.meetingLink != null && session.meetingLink!.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => _launchMeetingLink(session.meetingLink!),
              icon: const Icon(Icons.video_call),
              label: const Text('Join'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              context,
              'View All Sessions',
              Icons.event_note,
              Colors.blue,
              () => context.go('/my-sessions'),
            ),
            _buildActionButton(
              context,
              'Learning Materials',
              Icons.library_books,
              Colors.purple,
              () => context.go('/learning-materials'),
            ),
            _buildActionButton(
              context,
              'My Profile',
              Icons.person,
              Colors.teal,
              () => context.go('/profile'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading dashboard',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _refreshDashboard(context),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> _launchMeetingLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _refreshDashboard(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated && authState.user.linkedStudentId != null) {
      await context.read<StudentDashboardCubit>().refreshDashboard(
            studentId: authState.user.linkedStudentId!,
          );
    }
  }
}
