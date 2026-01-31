import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/models/teacher_model.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/teachers/presentation/cubit/teacher_cubit.dart';
import 'package:quran_gate_academy/features/teachers/presentation/cubit/teacher_state.dart';

/// Teachers Management Page for Admin
class TeachersPage extends StatelessWidget {
  const TeachersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TeacherCubit>()..loadTeachers(),
      child: const _TeachersView(),
    );
  }
}

class _TeachersView extends StatefulWidget {
  const _TeachersView();

  @override
  State<_TeachersView> createState() => _TeachersViewState();
}

class _TeachersViewState extends State<_TeachersView> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(
            currentRoute: '/teachers',
          ),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                _buildFilters(),
                Expanded(child: _buildTeachersList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateTeacher(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Teacher'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildHeader() {
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
            Icons.person,
            size: 32,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teacher Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
              ),
              Text(
                'Manage all teachers in the system',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.read<TeacherCubit>().loadTeachers(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Statuses')),
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
                _applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeachersList() {
    return BlocConsumer<TeacherCubit, TeacherState>(
      listener: (context, state) {
        if (state is TeacherDeactivated || state is TeacherActivated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state is TeacherDeactivated
                  ? 'Teacher deactivated successfully'
                  : 'Teacher activated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.read<TeacherCubit>().loadTeachers();
        } else if (state is TeacherError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TeacherLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TeachersLoaded) {
          if (state.teachers.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TeacherCubit>().loadTeachers();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildTeachersTable(state.teachers),
            ),
          );
        }

        if (state is TeacherError) {
          return _buildErrorState(state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTeachersTable(List<TeacherModel> teachers) {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppTheme.primaryColor.withOpacity(0.1),
          ),
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Hourly Rate')),
            DataColumn(label: Text('Specialization')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: teachers.map((teacher) => _buildTeacherRow(teacher)).toList(),
        ),
      ),
    );
  }

  DataRow _buildTeacherRow(TeacherModel teacher) {
    return DataRow(
      cells: [
        DataCell(Text(teacher.fullName)),
        DataCell(Text(teacher.email)),
        DataCell(Text(teacher.phone)),
        DataCell(Text('\$${teacher.hourlyRate.toStringAsFixed(2)}/hr')),
        DataCell(Text(teacher.specialization ?? '-')),
        DataCell(_buildStatusChip(teacher.status)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                tooltip: 'Edit',
                onPressed: () => _navigateToEditTeacher(context, teacher),
              ),
              IconButton(
                icon: Icon(
                  teacher.status == 'active' ? Icons.block : Icons.check_circle,
                  size: 18,
                  color: teacher.status == 'active' ? Colors.red : Colors.green,
                ),
                tooltip: teacher.status == 'active' ? 'Deactivate' : 'Activate',
                onPressed: () => _confirmToggleStatus(context, teacher),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final color = status == 'active' ? Colors.green : Colors.grey;
    final label = status == 'active' ? 'Active' : 'Inactive';

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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: AppTheme.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Teachers Found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first teacher to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Teachers',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.errorColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<TeacherCubit>().loadTeachers(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    context.read<TeacherCubit>().loadTeachers(status: _selectedStatus);
  }

  void _navigateToCreateTeacher(BuildContext context) {
    context.push('/teachers/create');
  }

  void _navigateToEditTeacher(BuildContext context, TeacherModel teacher) {
    context.push('/teachers/edit/${teacher.id}');
  }

  void _confirmToggleStatus(BuildContext context, TeacherModel teacher) {
    final isActive = teacher.status == 'active';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isActive ? 'Deactivate Teacher' : 'Activate Teacher'),
        content: Text(
          isActive
              ? 'Are you sure you want to deactivate ${teacher.fullName}? They will no longer be able to access the system.'
              : 'Are you sure you want to activate ${teacher.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (isActive) {
                context.read<TeacherCubit>().deactivateTeacher(teacher.id);
              } else {
                context.read<TeacherCubit>().activateTeacher(teacher.id);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppTheme.errorColor : Colors.green,
            ),
            child: Text(isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }
}
