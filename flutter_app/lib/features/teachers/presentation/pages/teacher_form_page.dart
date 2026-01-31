import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/teachers/presentation/cubit/teacher_cubit.dart';
import 'package:quran_gate_academy/features/teachers/presentation/cubit/teacher_state.dart';

/// Teacher Form Page for creating and editing teachers
class TeacherFormPage extends StatelessWidget {
  final String? teacherId;

  const TeacherFormPage({super.key, this.teacherId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<TeacherCubit>();
        if (teacherId != null) {
          cubit.loadTeacher(teacherId!);
        }
        return cubit;
      },
      child: _TeacherFormView(teacherId: teacherId),
    );
  }
}

class _TeacherFormView extends StatefulWidget {
  final String? teacherId;

  const _TeacherFormView({this.teacherId});

  @override
  State<_TeacherFormView> createState() => _TeacherFormViewState();
}

class _TeacherFormViewState extends State<_TeacherFormView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _specializationController = TextEditingController();

  bool _isEditMode = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.teacherId != null;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _hourlyRateController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/teachers'),
          Expanded(
            child: BlocConsumer<TeacherCubit, TeacherState>(
              listener: (context, state) {
                if (state is TeacherLoaded && _isEditMode) {
                  // Populate form fields with teacher data
                  _fullNameController.text = state.teacher.fullName;
                  _emailController.text = state.teacher.email;
                  _phoneController.text = state.teacher.phone;
                  _hourlyRateController.text =
                      state.teacher.hourlyRate.toString();
                  _specializationController.text =
                      state.teacher.specialization ?? '';
                }

                if (state is TeacherCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teacher created successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.go('/teachers');
                }

                if (state is TeacherUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teacher updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.go('/teachers');
                }

                if (state is TeacherError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TeacherLoading && _isEditMode) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildForm(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/teachers'),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? 'Edit Teacher' : 'Add New Teacher',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
            ),
            Text(
              _isEditMode
                  ? 'Update teacher information'
                  : 'Create a new teacher account',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teacher Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: !_isEditMode, // Email cannot be changed in edit mode
                decoration: InputDecoration(
                  labelText: 'Email *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                  helperText: _isEditMode ? 'Email cannot be changed' : null,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (!_isEditMode)
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
              if (!_isEditMode) const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hourlyRateController,
                decoration: const InputDecoration(
                  labelText: 'Hourly Rate (USD) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hourly rate';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate <= 0) {
                    return 'Please enter a valid hourly rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(
                  labelText: 'Specialization (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                  helperText: 'e.g., Tajweed, Memorization, Arabic',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(_isEditMode ? 'Update Teacher' : 'Create Teacher'),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => context.go('/teachers'),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final fullName = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final phone = _phoneController.text.trim();
      final hourlyRate = double.parse(_hourlyRateController.text);
      final specialization = _specializationController.text.trim();

      if (_isEditMode) {
        context.read<TeacherCubit>().updateTeacher(
              teacherId: widget.teacherId!,
              fullName: fullName,
              phone: phone,
              hourlyRate: hourlyRate,
              specialization: specialization.isNotEmpty ? specialization : null,
            );
      } else {
        context.read<TeacherCubit>().createTeacher(
              email: email,
              password: password,
              fullName: fullName,
              phone: phone,
              hourlyRate: hourlyRate,
              specialization: specialization.isNotEmpty ? specialization : null,
            );
      }
    }
  }
}
