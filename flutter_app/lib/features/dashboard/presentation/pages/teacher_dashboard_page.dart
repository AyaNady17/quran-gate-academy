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
        final cubit = getIt<TeacherDashboardCubit>();
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthAuthenticated) {
          cubit.loadDashboard(teacherId: authState.user.id);
        }
        return cubit;
      },
      child: const _TeacherDashboardContent(),
    );
  }
}

class _TeacherDashboardContent extends StatefulWidget {
  const _TeacherDashboardContent();

  @override
  State<_TeacherDashboardContent> createState() =>
      _TeacherDashboardContentState();
}

class _TeacherDashboardContentState extends State<_TeacherDashboardContent> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubitState = context.read<TeacherDashboardCubit>().state;
    if (cubitState is TeacherDashboardLoaded) {
      _startDate = cubitState.searchStartDate;
      _endDate = cubitState.searchEndDate;
      if (_startDate != null) {
        if (_startDate == _endDate || _endDate == null) {
          _dateController.text = DateFormat('MM/dd/yyyy').format(_startDate!);
        } else {
          _dateController.text =
              '${DateFormat('MM/dd/yyyy').format(_startDate!)} - ${DateFormat('MM/dd/yyyy').format(_endDate!)}';
        }
      }
    }
  }

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
        if (_startDate == _endDate) {
          _dateController.text = DateFormat('MM/dd/yyyy').format(_startDate!);
        } else {
          _dateController.text =
              '${DateFormat('MM/dd/yyyy').format(_startDate!)} - ${DateFormat('MM/dd/yyyy').format(_endDate!)}';
        }
      });
    }
  }

  void _search(BuildContext context) {
    if (_startDate == null) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<TeacherDashboardCubit>().searchSessionsByDate(
            teacherId: authState.user.id,
            startDate: _startDate!,
            endDate: _endDate,
          );
    }
  }

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
                              teacherId: authState.user.id,
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
                          // Today's Classes Section
                          _buildTodaySessions(
                            context,
                            state.todaySessions,
                            state.searchStartDate,
                            state.searchEndDate,
                          ),
                          const SizedBox(height: 32),
                          _buildUpcomingSessions(
                              context, state.upcomingSessions),
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
                              context
                                  .read<TeacherDashboardCubit>()
                                  .loadDashboard(
                                    teacherId: authState.user.id,
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

                if (state is TeacherDashboardInitial) {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthAuthenticated) {
                    context
                        .read<TeacherDashboardCubit>()
                        .loadDashboard(teacherId: authState.user.id);
                  }
                  return const Center(child: CircularProgressIndicator());
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

  Widget _buildTodaySessions(
      BuildContext context,
      List<ClassSessionModel> sessions,
      DateTime? searchStart,
      DateTime? searchEnd) {
    String title = 'Today\'s Classes';
    if (searchStart != null) {
      final startStr = DateFormat('MMM dd, yyyy').format(searchStart);
      if (searchEnd == null ||
          (searchStart.year == searchEnd.year &&
              searchStart.month == searchEnd.month &&
              searchStart.day == searchEnd.day)) {
        title = 'Classes for $startStr';
      } else {
        final endStr = DateFormat('MMM dd, yyyy').format(searchEnd);
        title = 'Classes: $startStr - $endStr';
      }
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'MM/DD/YYYY',
                      prefixIcon: const Icon(Icons.calendar_today),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: const OutlineInputBorder(),
                      suffixIcon: _startDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                  _dateController.clear();
                                });
                                final authState =
                                    context.read<AuthCubit>().state;
                                if (authState is AuthAuthenticated) {
                                  context
                                      .read<TeacherDashboardCubit>()
                                      .loadDashboard(
                                        teacherId: authState.user.id,
                                      );
                                }
                              },
                            )
                          : null,
                    ),
                    onTap: () => _pickDateRange(context),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _search(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sessions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'No data found',
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Class Time')),
                    DataColumn(label: Text('Student Name')),
                    DataColumn(label: Text('Course Name')),
                    DataColumn(label: Text('Class Status')),
                    DataColumn(label: Text('History')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: sessions.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final session = entry.value;
                    return DataRow(cells: [
                      DataCell(Text(index.toString())),
                      DataCell(Text(session.scheduledTime)),
                      DataCell(Text(session.studentName ?? session.studentId)),
                      DataCell(Text(session.courseId)),
                      DataCell(_buildStatusChip(session.status)),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.history, color: Colors.blue),
                          onPressed: () {
                            // TODO: View session history
                          },
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                // TODO: Show action menu
                              },
                            ),
                          ],
                        ),
                      ),
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
                      Icon(Icons.calendar_today,
                          size: 48, color: AppTheme.textSecondaryColor),
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
                      child:
                          const Icon(Icons.event, color: AppTheme.primaryColor),
                    ),
                    title: Text(
                      '${dateFormat.format(session.scheduledDate)} at ${session.scheduledTime}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Student: ${session.studentName ?? session.studentId} • ${session.duration} min',
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
