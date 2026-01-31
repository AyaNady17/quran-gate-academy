import 'package:quran_gate_academy/core/models/user_model.dart';
import 'package:quran_gate_academy/features/auth/data/services/auth_service.dart';
import 'package:quran_gate_academy/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;

  AuthRepositoryImpl({required this.authService});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // Login to Appwrite
      await authService.login(email: email, password: password);

      // Get account info
      final account = await authService.getCurrentAccount();

      // Get user profile from Users collection
      final profileData = await authService.getUserProfile(account.$id);

      return UserModel.fromJson(profileData);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final account = await authService.getCurrentAccount();
      final profileData = await authService.getUserProfile(account.$id);
      return UserModel.fromJson(profileData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await authService.logout();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await authService.isAuthenticated();
  }

  @override
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    double hourlyRate = 0,
    String? phone,
    String? specialization,
  }) async {
    try {
      // Create Appwrite account
      final account = await authService.createAccount(
        email: email,
        password: password,
        name: fullName,
      );

      // Create user profile in Users collection
      final profileData = await authService.createUserProfile(
        userId: account.$id,
        email: email,
        fullName: fullName,
        role: role,
        hourlyRate: hourlyRate,
        phone: phone,
        specialization: specialization,
      );

      return UserModel.fromJson(profileData);
    } catch (e) {
      throw Exception('User creation failed: $e');
    }
  }

  @override
  Future<UserModel> registerTeacher({
    required String email,
    required String password,
    required String fullName,
    required double hourlyRate,
    String? phone,
    String? specialization,
  }) async {
    try {
      // Register teacher account (creates account + profile + auto-login)
      final account = await authService.registerTeacher(
        email: email,
        password: password,
        fullName: fullName,
        hourlyRate: hourlyRate,
        phone: phone,
        specialization: specialization,
      );

      // Get the created user profile
      final profileData = await authService.getUserProfile(account.$id);
      return UserModel.fromJson(profileData);
    } catch (e) {
      throw Exception('Teacher registration failed: $e');
    }
  }
}
