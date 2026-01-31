import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:quran_gate_academy/core/config/app_config.dart';

/// Authentication service for Appwrite
class AuthService {
  final Account account;
  final Databases databases;

  AuthService({
    required this.account,
    required this.databases,
  });

  /// Login with email and password
  Future<models.Session> login({
    required String email,
    required String password,
  }) async {
    try {
      return await account.createEmailSession(
        email: email,
        password: password,
      );
    } on AppwriteException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }

  /// Get current user account
  Future<models.User> getCurrentAccount() async {
    try {
      return await account.get();
    } on AppwriteException catch (e) {
      throw Exception('Failed to get account: ${e.message}');
    }
  }

  /// Get user profile from Users collection
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.usersCollectionId,
        queries: [
          Query.equal('userId', userId),
        ],
      );

      if (response.documents.isEmpty) {
        throw Exception('User profile not found');
      }

      return response.documents.first.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to get user profile: ${e.message}');
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw Exception('Logout failed: ${e.message}');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      await account.get();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create new account (admin function)
  Future<models.User> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      return await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
    } on AppwriteException catch (e) {
      throw Exception('Account creation failed: ${e.message}');
    }
  }

  /// Create user profile in Users collection
  Future<Map<String, dynamic>> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String role,
    double hourlyRate = 0,
    String? phone,
    String? specialization,
  }) async {
    try {
      final response = await databases.createDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.usersCollectionId,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'email': email,
          'fullName': fullName,
          'role': role,
          'phone': phone,
          'hourlyRate': hourlyRate,
          'specialization': specialization,
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      return response.data;
    } on AppwriteException catch (e) {
      throw Exception('Failed to create user profile: ${e.message}');
    }
  }

  /// Register a new teacher account (self-registration)
  Future<models.User> registerTeacher({
    required String email,
    required String password,
    required String fullName,
    required double hourlyRate,
    String? phone,
    String? specialization,
  }) async {
    try {
      // 1. Create Appwrite account
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: fullName,
      );

      // 2. Create session (auto-login)
      await account.createEmailSession(
        email: email,
        password: password,
      );

      // 3. Create user profile in database
      await createUserProfile(
        userId: user.$id,
        email: email,
        fullName: fullName,
        role: AppConfig.roleTeacher,
        hourlyRate: hourlyRate,
        phone: phone,
        specialization: specialization,
      );

      return user;
    } on AppwriteException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    }
  }
}
