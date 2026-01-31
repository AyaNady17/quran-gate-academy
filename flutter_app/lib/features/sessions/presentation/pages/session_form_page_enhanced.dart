import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/models/student_model.dart';
import 'package:quran_gate_academy/core/models/teacher_model.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_cubit.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_state.dart';
import 'package:quran_gate_academy/features/students/data/services/student_service.dart';
import 'package:quran_gate_academy/features/teachers/data/services/teacher_service.dart';

/// Enhanced Session Create/Edit Form Page with real data
class SessionFormPageEnhanced extends StatelessWidget {
  final String? sessionId;

  const SessionFormPageEnhanced({
    super.key,
    this.sessionId,
  });

  bool get isEditing => sessionId != null;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return BlocProvider(
      create: (context) => getIt<SessionCubit>(param1: authState.user),
      child: _SessionFormView(sessionId: sessionId),
    );
  }
}

class _SessionFormView extends StatefulWidget {
  final String? sessionId;

  const _SessionFormView({this.sessionId});

  @override
  State<_SessionFormView> createState() => _SessionFormViewState();
}

class _SessionFormViewState extends State<_SessionFormView> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('yyyy-MM-dd');

  // Services
  late final TeacherService _teacherService;
  late final StudentService _studentService;

  // Form fields
  String? _teacherId;
  String? _studentId;
  final _courseId = 'default-course'; // Placeholder until courses implemented
  String? _planId;
  DateTime _scheduledDate = DateTime.now();
  final _scheduledTimeController = TextEditingController(text: '09:00');
  final _durationController = TextEditingController(text: '60');
  final _salaryAmountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  final _meetingLinkController = TextEditingController();

  // Data lists
  List<TeacherModel> _teachers = [];
  List<StudentModel> _students = [];
  bool _isLoadingData = true;
  String? _loadingError;

  // Selected teacher hourly rate for auto-calculation
  double? _selectedTeacherHourlyRate;

  bool get isEditing => widget.sessionId != null;

  @override
  void initState() {
    super.initState();
    _teacherService = getIt<TeacherService>();
    _studentService = getIt<StudentService>();
    _loadData();

    // Add listeners for auto-calculation
    _durationController.addListener(_calculateSalary);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
      _loadingError = null;
    });

    try {
      // Load teachers and students in parallel
      final results = await Future.wait([
        _teacherService.getAllTeachers(status: 'active'),
        _studentService.getAllStudents(status: 'active'),
      ]);

      final teachersData = results[0];
      final studentsData = results[1];

      setState(() {
        _teachers =
            teachersData.map((data) => TeacherModel.fromJson(data)).toList();
        _students =
            studentsData.map((data) => StudentModel.fromJson(data)).toList();
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _loadingError = 'Failed to load data: ${e.toString()}';
        _isLoadingData = false;
      });
    }
  }

  void _calculateSalary() {
    if (_selectedTeacherHourlyRate == null) return;

    final duration = int.tryParse(_durationController.text) ?? 0;
    if (duration <= 0) return;

    final hours = duration / 60.0;
    final salary = _selectedTeacherHourlyRate! * hours;

    setState(() {
      _salaryAmountController.text = salary.toStringAsFixed(2);
    });
  }

  @override
  void dispose() {
    _scheduledTimeController.dispose();
    _durationController.dispose();
    _salaryAmountController.dispose();
    _notesController.dispose();
    _meetingLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/sessions'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: BlocConsumer<SessionCubit, SessionState>(
                    listener: (context, state) {
                      if (state is SessionCreated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Session created successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        context.go('/sessions');
                      } else if (state is SessionUpdated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Session updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        context.go('/sessions');
                      } else if (state is SessionError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (_isLoadingData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (_loadingError != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(_loadingError!),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      return _buildForm(state is SessionLoading);
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
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/sessions'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Session' : 'Create New Session',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
              ),
              Text(
                isEditing
                    ? 'Update session details'
                    : 'Schedule a new class session',
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

  Widget _buildForm(bool isSubmitting) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Teacher Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _teacherId,
                      decoration: const InputDecoration(
                        labelText: 'Teacher *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _teachers.map((teacher) {
                        return DropdownMenuItem(
                          value: teacher.id,
                          child: Text(
                              '${teacher.fullName} (\$${teacher.hourlyRate}/hr)'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _teacherId = value;
                          // Find selected teacher and get hourly rate
                          final selectedTeacher =
                              _teachers.firstWhere((t) => t.id == value);
                          _selectedTeacherHourlyRate =
                              selectedTeacher.hourlyRate;
                          _calculateSalary();
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a teacher';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Student Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _studentId,
                      decoration: const InputDecoration(
                        labelText: 'Student *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      items: _students.map((student) {
                        return DropdownMenuItem(
                          value: student.id,
                          child: Text(student.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _studentId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a student';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date Picker
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _scheduledDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            _scheduledDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Scheduled Date *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(_dateFormat.format(_scheduledDate)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time Picker
                    TextFormField(
                      controller: _scheduledTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Scheduled Time (HH:mm) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                        hintText: '09:00',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter scheduled time';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Duration
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timer),
                        helperText:
                            'Auto-calculates salary based on hourly rate',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter duration';
                        }
                        final duration = int.tryParse(value);
                        if (duration == null || duration <= 0) {
                          return 'Please enter a valid duration';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Salary Amount (auto-calculated)
                    TextFormField(
                      controller: _salaryAmountController,
                      decoration: InputDecoration(
                        labelText: 'Salary Amount (USD)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.attach_money),
                        helperText: _selectedTeacherHourlyRate != null
                            ? 'Auto-calculated: \$${_selectedTeacherHourlyRate!.toStringAsFixed(2)}/hr × ${_durationController.text} min'
                            : 'Select teacher to auto-calculate',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      enabled: false,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Meeting Link
                    TextFormField(
                      controller: _meetingLinkController,
                      decoration: const InputDecoration(
                        labelText: 'Meeting Link (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                        hintText: 'https://zoom.us/j/...',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isEditing
                                  ? 'Update Session'
                                  : 'Create Session'),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () => context.go('/sessions'),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final salaryAmount = double.tryParse(_salaryAmountController.text) ?? 0.0;
      final duration = int.parse(_durationController.text);
      final scheduledTime = _scheduledTimeController.text;
      final notes = _notesController.text.trim();
      final meetingLink = _meetingLinkController.text.trim();

      context.read<SessionCubit>().createSession(
            teacherId: _teacherId!,
            studentId: _studentId!,
            courseId: _courseId,
            planId: _planId,
            scheduledDate: _scheduledDate,
            scheduledTime: scheduledTime,
            duration: duration,
            salaryAmount: salaryAmount,
            notes: notes.isNotEmpty ? notes : null,
            meetingLink: meetingLink.isNotEmpty ? meetingLink : null,
            createdBy: 'admin', // TODO: Get from auth context
          );
    }
  }
}
