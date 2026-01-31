import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_cubit.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_state.dart';

/// Session Create/Edit Form Page
class SessionFormPage extends StatelessWidget {
  final String? sessionId;

  const SessionFormPage({
    super.key,
    this.sessionId,
  });

  bool get isEditing => sessionId != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SessionCubit>(),
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

  // Form fields
  String? _teacherId;
  String? _studentId;
  String? _courseId;
  String? _planId;
  DateTime _scheduledDate = DateTime.now();
  final _scheduledTimeController = TextEditingController(text: '09:00');
  final _durationController = TextEditingController(text: '60');
  final _salaryAmountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  final _meetingLinkController = TextEditingController();

  // Mock data - In production, fetch from services
  final List<Map<String, String>> _teachers = [
    {'id': 'teacher1', 'name': 'Ahmed Hassan'},
    {'id': 'teacher2', 'name': 'Fatima Ali'},
    {'id': 'teacher3', 'name': 'Mohammed Yusuf'},
  ];

  final List<Map<String, String>> _students = [
    {'id': 'student1', 'name': 'Sara Ibrahim'},
    {'id': 'student2', 'name': 'Omar Abdullah'},
    {'id': 'student3', 'name': 'Aisha Rahman'},
  ];

  final List<Map<String, String>> _courses = [
    {'id': 'course1', 'name': 'Quran Recitation - Beginner'},
    {'id': 'course2', 'name': 'Tajweed Rules - Intermediate'},
    {'id': 'course3', 'name': 'Quran Memorization - Advanced'},
  ];

  bool get isEditing => widget.sessionId != null;

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
          const AppSidebar(
            currentRoute: '/sessions',
          ),
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
            onPressed: () => context.go('/sessions'),
            icon: const Icon(Icons.arrow_back),
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

  Widget _buildForm(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      decoration: const InputDecoration(
                        labelText: 'Teacher *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _teachers
                          .map((teacher) => DropdownMenuItem(
                                value: teacher['id'],
                                child: Text(teacher['name']!),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _teacherId = value;
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
                      decoration: const InputDecoration(
                        labelText: 'Student *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: _students
                          .map((student) => DropdownMenuItem(
                                value: student['id'],
                                child: Text(student['name']!),
                              ))
                          .toList(),
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

                    // Course Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Course *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                      items: _courses
                          .map((course) => DropdownMenuItem(
                                value: course['id'],
                                child: Text(course['name']!),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _courseId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a course';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date and Time Row
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Scheduled Date *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(_dateFormat.format(_scheduledDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _scheduledTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Scheduled Time *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.access_time),
                              hintText: 'HH:MM (e.g., 09:00)',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter time';
                              }
                              // Simple time validation
                              if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
                                return 'Use HH:MM format';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Duration and Salary Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _durationController,
                            decoration: const InputDecoration(
                              labelText: 'Duration (minutes) *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.timer),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter duration';
                              }
                              final duration = int.tryParse(value);
                              if (duration == null || duration <= 0) {
                                return 'Must be greater than 0';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _salaryAmountController,
                            decoration: const InputDecoration(
                              labelText: 'Salary Amount *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter salary amount';
                              }
                              final salary = double.tryParse(value);
                              if (salary == null || salary < 0) {
                                return 'Must be 0 or greater';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Meeting Link
                    TextFormField(
                      controller: _meetingLinkController,
                      decoration: const InputDecoration(
                        labelText: 'Meeting Link (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                        hintText: 'https://...',
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
                        hintText: 'Additional notes or instructions',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isLoading ? null : () => context.go('/sessions'),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(isEditing ? 'Update Session' : 'Create Session'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _scheduledDate) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final duration = int.parse(_durationController.text);
      final salaryAmount = double.parse(_salaryAmountController.text);

      if (isEditing) {
        context.read<SessionCubit>().updateSession(
              sessionId: widget.sessionId!,
              teacherId: _teacherId,
              studentId: _studentId,
              courseId: _courseId,
              planId: _planId,
              scheduledDate: _scheduledDate,
              scheduledTime: _scheduledTimeController.text,
              duration: duration,
              salaryAmount: salaryAmount,
              notes: _notesController.text.isNotEmpty ? _notesController.text : null,
              meetingLink: _meetingLinkController.text.isNotEmpty
                  ? _meetingLinkController.text
                  : null,
            );
      } else {
        context.read<SessionCubit>().createSession(
              teacherId: _teacherId!,
              studentId: _studentId!,
              courseId: _courseId!,
              planId: _planId,
              scheduledDate: _scheduledDate,
              scheduledTime: _scheduledTimeController.text,
              duration: duration,
              salaryAmount: salaryAmount,
              notes: _notesController.text.isNotEmpty ? _notesController.text : null,
              meetingLink: _meetingLinkController.text.isNotEmpty
                  ? _meetingLinkController.text
                  : null,
            );
      }
    }
  }
}
