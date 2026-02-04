import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/students/presentation/cubit/student_cubit.dart';
import 'package:quran_gate_academy/features/students/presentation/cubit/student_state.dart';
import 'dart:math';

/// Student Form Page - Create or Edit Student
class StudentFormPage extends StatefulWidget {
  final String? studentId;

  const StudentFormPage({
    super.key,
    this.studentId,
  });

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _countryController = TextEditingController();
  final _countryCodeController = TextEditingController();
  final _timezoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _accountEmailController = TextEditingController();
  final _accountPasswordController = TextEditingController();

  String _status = 'active';
  bool _isLoading = true;
  bool _createUserAccount = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.studentId != null) {
      _loadStudent();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadStudent() async {
    final cubit = getIt<StudentCubit>();
    await cubit.loadStudent(widget.studentId!);
    final state = cubit.state;
    if (state is StudentLoaded) {
      setState(() {
        _fullNameController.text = state.student.fullName;
        _emailController.text = state.student.email ?? '';
        _phoneController.text = state.student.phone ?? '';
        _whatsappController.text = state.student.whatsapp ?? '';
        _countryController.text = state.student.country ?? '';
        _countryCodeController.text = state.student.countryCode ?? '';
        _timezoneController.text = state.student.timezone ?? '';
        _notesController.text = state.student.notes ?? '';
        _status = state.student.status;
        _isLoading = false;
      });
    } else if (state is StudentError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        context.go('/students');
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _countryController.dispose();
    _countryCodeController.dispose();
    _timezoneController.dispose();
    _notesController.dispose();
    _accountEmailController.dispose();
    _accountPasswordController.dispose();
    super.dispose();
  }

  String _generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%';
    final random = Random.secure();
    return List.generate(12, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StudentCubit>(),
      child: Scaffold(
        body: Row(
          children: [
            const AppSidebar(currentRoute: '/students'),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildFormContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return BlocConsumer<StudentCubit, StudentState>(
      listener: (context, state) {
        if (state is StudentCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/students');
        } else if (state is StudentCreatedWithAccount) {
          // Show success dialog with account credentials
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  const Text('Success!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student and user account created successfully!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const Text('Account Credentials:'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.email, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.accountEmail,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 16),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: state.accountEmail));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Email copied')),
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            const Icon(Icons.lock, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.accountPassword,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 16),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: state.accountPassword));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Password copied')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, size: 20, color: Colors.amber.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Make sure to securely save these credentials before closing this dialog.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/students');
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        } else if (state is StudentUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/students');
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
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBasicInfoSection(),
                        const SizedBox(height: 24),
                        _buildContactSection(),
                        const SizedBox(height: 24),
                        _buildLocationSection(),
                        const SizedBox(height: 24),
                        _buildNotesSection(),
                        const SizedBox(height: 24),
                        if (widget.studentId == null) _buildAccountCreationSection(),
                        if (widget.studentId == null) const SizedBox(height: 24),
                        if (widget.studentId != null) _buildStatusSection(),
                        const SizedBox(height: 32),
                        _buildActionButtons(context, state),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.go('/students'),
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.studentId != null ? 'Edit Student' : 'Add New Student',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              widget.studentId != null
                  ? 'Update student information'
                  : 'Enter student details',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Full name is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.chat),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location & Timezone',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _countryCodeController,
                decoration: const InputDecoration(
                  labelText: 'Country Code',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., +1, +44',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _timezoneController,
          decoration: const InputDecoration(
            labelText: 'Timezone',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.access_time),
            hintText: 'e.g., America/New_York, Europe/London',
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(),
            hintText: 'Any additional information about the student',
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildAccountCreationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'User Account (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            Switch(
              value: _createUserAccount,
              onChanged: (value) {
                setState(() {
                  _createUserAccount = value;
                  if (value) {
                    // Pre-fill email from student email if available
                    if (_emailController.text.isNotEmpty) {
                      _accountEmailController.text = _emailController.text;
                    }
                    // Generate initial password
                    _accountPasswordController.text = _generatePassword();
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Create a user account to allow the student to login',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
        ),
        if (_createUserAccount) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Email
                TextFormField(
                  controller: _accountEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Account Email *',
                    hintText: 'student@example.com',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (_createUserAccount) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required for account creation';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Account Password
                TextFormField(
                  controller: _accountPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    hintText: 'Generated password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          tooltip: _passwordVisible ? 'Hide password' : 'Show password',
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            setState(() {
                              _accountPasswordController.text = _generatePassword();
                            });
                          },
                          tooltip: 'Generate new password',
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _accountPasswordController.text),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          tooltip: 'Copy password',
                        ),
                      ],
                    ),
                  ),
                  obscureText: !_passwordVisible,
                  validator: (value) {
                    if (_createUserAccount) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required for account creation';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.amber.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Make sure to copy and securely share this password with the student. They can change it after first login.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.amber.shade900,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'active', child: Text('Active')),
            DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
            DropdownMenuItem(value: 'graduated', child: Text('Graduated')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _status = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, StudentState state) {
    final isLoading = state is StudentLoading;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: isLoading ? null : () => context.go('/students'),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: isLoading ? null : () => _handleSubmit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.studentId != null
                      ? 'Update Student'
                      : _createUserAccount
                          ? 'Create Student & Account'
                          : 'Create Student',
                ),
        ),
      ],
    );
  }

  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cubit = context.read<StudentCubit>();

    if (widget.studentId != null) {
      // Update existing student
      cubit.updateStudent(
        studentId: widget.studentId!,
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        whatsapp: _whatsappController.text.trim().isEmpty
            ? null
            : _whatsappController.text.trim(),
        country: _countryController.text.trim().isEmpty
            ? null
            : _countryController.text.trim(),
        countryCode: _countryCodeController.text.trim().isEmpty
            ? null
            : _countryCodeController.text.trim(),
        timezone: _timezoneController.text.trim().isEmpty
            ? null
            : _timezoneController.text.trim(),
        status: _status,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    } else {
      // Create new student
      if (_createUserAccount) {
        // Create student with account
        cubit.createStudentWithAccount(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          whatsapp: _whatsappController.text.trim().isEmpty
              ? null
              : _whatsappController.text.trim(),
          country: _countryController.text.trim().isEmpty
              ? null
              : _countryController.text.trim(),
          countryCode: _countryCodeController.text.trim().isEmpty
              ? null
              : _countryCodeController.text.trim(),
          timezone: _timezoneController.text.trim().isEmpty
              ? null
              : _timezoneController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          accountEmail: _accountEmailController.text.trim(),
          accountPassword: _accountPasswordController.text,
        );
      } else {
        // Create student only
        cubit.createStudent(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          whatsapp: _whatsappController.text.trim().isEmpty
              ? null
              : _whatsappController.text.trim(),
          country: _countryController.text.trim().isEmpty
              ? null
              : _countryController.text.trim(),
          countryCode: _countryCodeController.text.trim().isEmpty
              ? null
              : _countryCodeController.text.trim(),
          timezone: _timezoneController.text.trim().isEmpty
              ? null
              : _timezoneController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      }
    }
  }
}
