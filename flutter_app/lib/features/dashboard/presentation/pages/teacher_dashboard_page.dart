import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/core/widgets/stat_card.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/teacher_dashboard_cubit.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/teacher_dashboard_state.dart';

/// Teacher Dashboard Page - Shows personal statistics and sessions
class TeacherDashboardPage extends StatelessWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthCubit>().state;
        final cubit = getIt<TeacherDashboardCubit>();
        if (authState is AuthAuthenticated) {
          cubit.loadDashboard(teacherId: authState.user.userId);
        }
        return cubit;
      },
      child: const _TeacherDashboardContent(),
    );
  }
}

class _TeacherDashboardContent extends StatelessWidget {
  const _TeacherDashboardContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/'),
          Expanded(
            child: BlocConsumer<TeacherDashboardCubit, TeacherDashboardState>(
              listener: (context, state) {
                if (state is TeacherDashboardError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TeacherDashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TeacherDashboardLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      final authState = context.read<AuthCubit>().state;
                      if (authState is AuthAuthenticated) {
                        context.read<TeacherDashboardCubit>().refreshDashboard(
                              teacherId: authState.user.userId,
                            );
                      }
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 32),
                          _buildStatsGrid(state.stats),
                          const SizedBox(height: 32),
                          _buildSalaryCard(context, state.stats),
                          const SizedBox(height: 32),
                          _buildTodaySessions(context, state.todaySessions),
                          const SizedBox(height: 32),
                          _buildUpcomingSessions(context, state.upcomingSessions),
                        ],
                      ),
                    ),
                  );
                }

                if (state is TeacherDashboardError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: AppTheme.errorColor),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Dashboard',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            final authState = context.read<AuthCubit>().state;
                            if (authState is AuthAuthenticated) {
                              context.read<TeacherDashboardCubit>().loadDashboard(
                                    teacherId: authState.user.userId,
                                  );
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final userName = authState is AuthAuthenticated
            ? authState.user.fullName
            : 'Teacher';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $userName!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Here\'s your teaching summary for this month',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid(TeacherDashboardStats stats) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'Total Hours',
          value: stats.monthlyHours.toStringAsFixed(1),
          subtitle: 'This Month',
          color: AppTheme.primaryColor,
          icon: Icons.access_time,
        ),
        StatCard(
          title: 'Total Sessions',
          value: stats.totalSessions.toString(),
          subtitle: '${stats.completedSessions} Completed',
          color: AppTheme.successColor,
          icon: Icons.event,
        ),
        StatCard(
          title: 'Attendance',
          value: '${stats.attendancePercentage.toStringAsFixed(1)}%',
          subtitle: 'Success Rate',
          color: AppTheme.warningColor,
          icon: Icons.check_circle,
        ),
        StatCard(
          title: 'Today\'s Classes',
          value: stats.todaySessionsCount.toString(),
          subtitle: 'Scheduled Today',
          color: AppTheme.infoColor,
          icon: Icons.today,
        ),
      ],
    );
  }

  Widget _buildSalaryCard(BuildContext context, TeacherDashboardStats stats) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.successColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.attach_money,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Earnings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${stats.monthlySalary.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'From ${stats.completedSessions} completed sessions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySessions(BuildContext context, List<ClassSessionModel> sessions) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Classes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 48, color: AppTheme.textSecondaryColor),
                      SizedBox(height: 8),
                      Text('No classes scheduled for today'),
                    ],
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Time')),
                    DataColumn(label: Text('Student')),
                    DataColumn(label: Text('Course')),
                    DataColumn(label: Text('Duration')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: sessions.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final session = entry.value;
                    return DataRow(cells: [
                      DataCell(Text(index.toString())),
                      DataCell(Text(session.scheduledTime)),
                      DataCell(Text(session.studentId)), // TODO: Fetch name
                      DataCell(Text(session.courseId)), // TODO: Fetch name
                      DataCell(Text('${session.duration} min')),
                      DataCell(_buildStatusChip(session.status)),
                    ]);
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSessions(
      BuildContext context, List<ClassSessionModel> sessions) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today, size: 48, color: AppTheme.textSecondaryColor),
                      SizedBox(height: 8),
                      Text('No upcoming sessions'),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length > 5 ? 5 : sessions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: const Icon(Icons.event, color: AppTheme.primaryColor),
                    ),
                    title: Text(
                      '${dateFormat.format(session.scheduledDate)} at ${session.scheduledTime}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Student: ${session.studentId} • ${session.duration} min',
                    ),
                    trailing: _buildStatusChip(session.status),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'scheduled':
        color = Colors.blue;
        label = 'Scheduled';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'in_progress':
        color = Colors.orange;
        label = 'In Progress';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
