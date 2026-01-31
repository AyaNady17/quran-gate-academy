import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/core/router/app_router.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/core/widgets/stat_card.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/admin_dashboard_cubit.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/admin_dashboard_state.dart';

/// Admin Dashboard Page - Shows system-wide statistics and management
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AdminDashboardCubit>()..loadDashboard(),
      child: const _AdminDashboardContent(),
    );
  }
}

class _AdminDashboardContent extends StatelessWidget {
  const _AdminDashboardContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/'),
          Expanded(
            child: BlocConsumer<AdminDashboardCubit, AdminDashboardState>(
              listener: (context, state) {
                if (state is AdminDashboardError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AdminDashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AdminDashboardLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AdminDashboardCubit>().refreshDashboard();
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
                          _buildQuickActions(context),
                          const SizedBox(height: 32),
                          _buildRecentSessions(context, state.recentSessions),
                        ],
                      ),
                    ),
                  );
                }

                if (state is AdminDashboardError) {
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
                          onPressed: () => context
                              .read<AdminDashboardCubit>()
                              .loadDashboard(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'System overview and management',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(AdminDashboardStats stats) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'Total Teachers',
          value: stats.totalTeachers.toString(),
          subtitle: '${stats.activeTeachers} Active',
          color: AppTheme.primaryColor,
          icon: Icons.person,
        ),
        StatCard(
          title: 'Total Students',
          value: stats.totalStudents.toString(),
          subtitle: '${stats.activeStudents} Active',
          color: AppTheme.successColor,
          icon: Icons.school,
        ),
        StatCard(
          title: 'Total Sessions',
          value: stats.totalSessions.toString(),
          subtitle: '${stats.completedSessions} Completed',
          color: AppTheme.warningColor,
          icon: Icons.event,
        ),
        StatCard(
          title: 'Monthly Revenue',
          value: '\$${stats.monthlyRevenue.toStringAsFixed(0)}',
          subtitle: 'This Month',
          color: AppTheme.infoColor,
          icon: Icons.attach_money,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
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
                _QuickActionButton(
                  icon: Icons.add,
                  label: 'New Session',
                  color: AppTheme.primaryColor,
                  onTap: () => context.go(AppRouter.sessionsRoute + '/create'),
                ),
                _QuickActionButton(
                  icon: Icons.person_add,
                  label: 'Add Teacher',
                  color: AppTheme.successColor,
                  onTap: () {
                    // TODO: Navigate to add teacher page (Phase 4)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Teacher management coming in Phase 4'),
                      ),
                    );
                  },
                ),
                _QuickActionButton(
                  icon: Icons.school,
                  label: 'Add Student',
                  color: AppTheme.infoColor,
                  onTap: () => context.go(AppRouter.studentsRoute),
                ),
                _QuickActionButton(
                  icon: Icons.event_note,
                  label: 'View Sessions',
                  color: AppTheme.warningColor,
                  onTap: () => context.go(AppRouter.sessionsRoute),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions(
      BuildContext context, List<ClassSessionModel> sessions) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Sessions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () => context.go(AppRouter.sessionsRoute),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No recent sessions'),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Time')),
                    DataColumn(label: Text('Teacher')),
                    DataColumn(label: Text('Student')),
                    DataColumn(label: Text('Duration')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: sessions.map((session) {
                    return DataRow(cells: [
                      DataCell(Text(dateFormat.format(session.scheduledDate))),
                      DataCell(Text(session.scheduledTime)),
                      DataCell(Text(session.teacherName ?? session.teacherId)),
                      DataCell(Text(session.studentName ?? session.studentId)),
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

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
