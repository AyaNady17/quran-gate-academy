import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:quran_gate_academy/core/models/class_session_model.dart';
import 'package:quran_gate_academy/core/utils/name_cache.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';
import 'package:quran_gate_academy/features/dashboard/domain/repositories/student_dashboard_repository.dart';
import 'package:quran_gate_academy/features/teachers/domain/repositories/teacher_repository.dart';
import 'package:url_launcher/url_launcher.dart';

/// Student sessions page showing all sessions in tabs
class StudentSessionsPage extends StatefulWidget {
  const StudentSessionsPage({super.key});

  @override
  State<StudentSessionsPage> createState() => _StudentSessionsPageState();
}

class _StudentSessionsPageState extends State<StudentSessionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;
  List<ClassSessionModel> _allSessions = [];
  List<ClassSessionModel> _upcomingSessions = [];
  List<ClassSessionModel> _completedSessions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSessions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated ||
          authState.user.linkedStudentId == null) {
        throw Exception('Not authenticated as student');
      }

      final studentId = authState.user.linkedStudentId!;
      final repository = GetIt.I<StudentDashboardRepository>();
      final teacherRepository = GetIt.I<TeacherRepository>();

      // Fetch all sessions
      final allSessions = await repository.getAllSessions(studentId: studentId);

      // Cache teacher names
      final missingTeacherIds = allSessions
          .map((s) => s.teacherId)
          .where((id) => !NameCache.hasTeacher(id))
          .toSet();

      if (missingTeacherIds.isNotEmpty) {
        final teachers = await teacherRepository.getAllTeachers();
        for (var teacher in teachers) {
          NameCache.cacheTeacherName(teacher.id, teacher.fullName);
        }
      }

      // Populate teacher names
      final populatedSessions = allSessions.map((session) {
        return session.copyWith(
          teacherName:
              NameCache.getTeacherName(session.teacherId) ?? 'Unknown Teacher',
        );
      }).toList();

      // Split into categories
      final now = DateTime.now();
      final upcoming = populatedSessions
          .where((s) =>
              s.status == 'scheduled' && s.scheduledDate.isAfter(now))
          .toList();
      final completed = populatedSessions
          .where((s) => s.status == 'completed')
          .toList();

      setState(() {
        _allSessions = populatedSessions;
        _upcomingSessions = upcoming;
        _completedSessions = completed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
                _buildTabBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? _buildErrorState()
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _buildSessionsList(_upcomingSessions, 'upcoming'),
                                _buildSessionsList(_completedSessions, 'completed'),
                                _buildSessionsList(_allSessions, 'all'),
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
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Sessions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'View all your scheduled and completed sessions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.schedule),
                const SizedBox(width: 8),
                Text('Upcoming (${_upcomingSessions.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle),
                const SizedBox(width: 8),
                Text('Completed (${_completedSessions.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.list),
                const SizedBox(width: 8),
                Text('All (${_allSessions.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(List<ClassSessionModel> sessions, String type) {
    if (sessions.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: _loadSessions,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          return _buildSessionCard(sessions[index]);
        },
      ),
    );
  }

  Widget _buildSessionCard(ClassSessionModel session) {
    final dateFormat = DateFormat('EEEE, MMM dd, yyyy');
    final isToday = _isToday(session.scheduledDate);
    final isUpcoming = session.scheduledDate.isAfter(DateTime.now());
    final showMeetingLink = (isToday || isUpcoming) &&
        session.meetingLink != null &&
        session.meetingLink!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(session.status).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(session.scheduledDate),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${session.scheduledTime} • ${session.duration} minutes',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(session.status),
              ],
            ),
          ),

          // Body with details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Teacher: ${session.teacherName ?? "Unknown"}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
                if (session.notes != null && session.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            session.notes!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (showMeetingLink) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchMeetingLink(session.meetingLink!),
                      icon: const Icon(Icons.video_call),
                      label: const Text('Join Meeting'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'absent':
        return Colors.orange;
      case 'student_cancel':
      case 'teacher_cancel':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(String type) {
    String message;
    IconData icon;

    switch (type) {
      case 'upcoming':
        message = 'No upcoming sessions scheduled';
        icon = Icons.schedule;
        break;
      case 'completed':
        message = 'No completed sessions yet';
        icon = Icons.check_circle_outline;
        break;
      default:
        message = 'No sessions found';
        icon = Icons.inbox;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading sessions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadSessions,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _launchMeetingLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
