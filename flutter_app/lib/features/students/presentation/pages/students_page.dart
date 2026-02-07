import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/models/student_model.dart';
import 'package:quran_gate_academy/core/services/permission_service.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';
import 'package:quran_gate_academy/features/students/presentation/cubit/student_cubit.dart';
import 'package:quran_gate_academy/features/students/presentation/cubit/student_state.dart';
import 'package:quran_gate_academy/features/students/presentation/widgets/create_student_account_dialog.dart';

/// Students page - Manage students and view their information
class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StudentCubit>()..loadStudents(),
      child: const _StudentsView(),
    );
  }
}

class _StudentsView extends StatelessWidget {
  const _StudentsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/students'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildStudentsList(context)),
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
            Icons.people,
            size: 32,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Students',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
              ),
              Text(
                'View and manage your students',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              context.read<StudentCubit>().loadStudents();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          // Only admins can add students
          ...() {
            final authState = context.read<AuthCubit>().state;
            if (authState is AuthAuthenticated &&
                PermissionService.canManageStudents(authState.user)) {
              return [
                ElevatedButton.icon(
                  onPressed: () => context.go('/students/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Student'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
              ];
            }
            return <Widget>[];
          }(),
        ],
      ),
    );
  }

  Widget _buildStudentsList(BuildContext context) {
    return BlocConsumer<StudentCubit, StudentState>(
      listener: (context, state) {
        if (state is StudentDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.read<StudentCubit>().loadStudents();
        } else if (state is StudentUserAccountCreated) {
          // Reload students list when account is created
          context.read<StudentCubit>().loadStudents();
        } else if (state is StudentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is StudentLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StudentsLoaded) {
          if (state.students.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildStudentsTable(context, state.students);
        }

        if (state is StudentError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<StudentCubit>().loadStudents();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppTheme.textTertiaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No students found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get started by adding your first student',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/students/new'),
            icon: const Icon(Icons.add),
            label: const Text('Add Student'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTable(BuildContext context, List<StudentModel> students) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${students.length} Students',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('WhatsApp')),
                  DataColumn(label: Text('Country')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: students.map((student) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                student.fullName[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(student.fullName),
                          ],
                        ),
                      ),
                      DataCell(Text(student.email ?? '-')),
                      DataCell(Text(student.phone ?? '-')),
                      DataCell(Text(student.whatsapp ?? '-')),
                      DataCell(Text(student.country ?? '-')),
                      DataCell(
                        Chip(
                          label: Text(
                            student.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(student.status),
                            ),
                          ),
                          backgroundColor: _getStatusColor(student.status).withOpacity(0.1),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Only admins can manage students
                            ...() {
                              final authState = context.read<AuthCubit>().state;
                              if (authState is AuthAuthenticated &&
                                  PermissionService.canManageStudents(authState.user)) {
                                return [
                                  // Create Account button (only if student doesn't have a user account)
                                  if (student.userId == null)
                                    IconButton(
                                      icon: const Icon(Icons.person_add, size: 20),
                                      color: Colors.green,
                                      onPressed: () {
                                        _showCreateAccountDialog(context, student);
                                      },
                                      tooltip: 'Create User Account',
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () {
                                      context.go('/students/edit/${student.id}');
                                    },
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    color: AppTheme.errorColor,
                                    onPressed: () {
                                      _confirmDelete(context, student);
                                    },
                                    tooltip: 'Delete',
                                  ),
                                ];
                              }
                              return <Widget>[];
                            }(),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'graduated':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showCreateAccountDialog(BuildContext context, StudentModel student) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<StudentCubit>(),
        child: CreateStudentAccountDialog(student: student),
      ),
    );

    // Reload students list if account was created successfully
    if (result == true && context.mounted) {
      context.read<StudentCubit>().loadStudents();
    }
  }

  void _confirmDelete(BuildContext context, StudentModel student) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text(
          'Are you sure you want to delete ${student.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<StudentCubit>().deleteStudent(student.id);
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
