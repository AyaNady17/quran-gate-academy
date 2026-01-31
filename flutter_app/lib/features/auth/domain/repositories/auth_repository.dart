import 'package:quran_gate_academy/core/models/user_model.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login with email and password
  Future<UserModel> login({required String email, required String password});

  /// Get current authenticated user
  Future<UserModel?> getCurrentUser();

  /// Logout current user
  Future<void> logout();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Create new user account and profile (admin function)
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    double hourlyRate,
    String? phone,
    String? specialization,
  });

  /// Register a new teacher account (self-registration)
  Future<UserModel> registerTeacher({
    required String email,
    required String password,
    required String fullName,
    required double hourlyRate,
    String? phone,
    String? specialization,
  });
}
