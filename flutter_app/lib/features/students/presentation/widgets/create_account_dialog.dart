import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';
import 'package:quran_gate_academy/core/models/student_model.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'dart:math';

/// Dialog for creating a user account for a student
class CreateAccountDialog extends StatefulWidget {
  final StudentModel student;

  const CreateAccountDialog({
    super.key,
    required this.student,
  });

  @override
  State<CreateAccountDialog> createState() => _CreateAccountDialogState();
}

class _CreateAccountDialogState extends State<CreateAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pre-fill email if student has one
    if (widget.student.email != null && widget.student.email!.isNotEmpty) {
      _emailController.text = widget.student.email!;
    }
    // Generate a random password
    _passwordController.text = _generatePassword();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%';
    final random = Random.secure();
    return List.generate(12, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create user account
      final account = AppConfig.account;
      final databases = AppConfig.databases;

      // Check if student already has a userId
      if (widget.student.userId != null && widget.student.userId!.isNotEmpty) {
        throw Exception('This student already has a user account linked.');
      }

      // Create auth account (without name to avoid uniqueness conflicts)
      final user = await account.create(
        userId: 'unique()',
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Update user document with role and linkedStudentId
      await databases.createDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.usersCollectionId,
        documentId: user.$id,
        data: {
          'email': _emailController.text.trim(),
          'fullName': widget.student.fullName,
          'role': AppConfig.roleStudent,
          'linkedStudentId': widget.student.id,
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      // Update student document with userId
      await databases.updateDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.studentsCollectionId,
        documentId: widget.student.id,
        data: {
          'userId': user.$id,
        },
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      // Better error messages
      String errorMessage = 'Failed to create account. ';

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('rate limit') || errorStr.contains('too many requests')) {
        errorMessage += 'Too many account creation requests. Please wait a minute and try again.';
      } else if (errorStr.contains('email') && errorStr.contains('already')) {
        errorMessage += 'This email is already registered. Please use a different email address.';
      } else if (errorStr.contains('already has a user account')) {
        errorMessage += e.toString().replaceAll('Exception: ', '');
      } else if (errorStr.contains('invalid email')) {
        errorMessage += 'Please enter a valid email address.';
      } else if (errorStr.contains('network')) {
        errorMessage += 'Network error. Please check your connection and try again.';
      } else {
        errorMessage += e.toString().replaceAll('Exception: ', '').replaceAll('AppwriteException: ', '');
      }

      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.person_add, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          const Text('Create User Account'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a user account for ${widget.student.fullName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
              const SizedBox(height: 24),

              // Student Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Information',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Name', widget.student.fullName),
                    if (widget.student.phone != null)
                      _buildInfoRow('Phone', widget.student.phone!),
                    if (widget.student.country != null)
                      _buildInfoRow('Country', widget.student.country!),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address *',
                  hintText: 'student@example.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  hintText: 'Enter password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
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
                            _passwordController.text = _generatePassword();
                          });
                        },
                        tooltip: 'Generate new password',
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: _passwordController.text),
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
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Make sure to copy and securely share this password with the student. They can change it after first login.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              // Error message
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 20, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red.shade700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _createAccount,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(_isLoading ? 'Creating...' : 'Create Account'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
