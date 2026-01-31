import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/features/auth/domain/repositories/auth_repository.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';

/// Authentication Cubit for managing auth state
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  /// Check authentication status on app start
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final isAuth = await authRepository.isAuthenticated();
      if (isAuth) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  /// Login with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  /// Logout current user
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Get current authenticated user
  Future<void> getCurrentUser() async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  /// Register a new teacher account
  Future<void> registerTeacher({
    required String email,
    required String password,
    required String fullName,
    required double hourlyRate,
    String? phone,
    String? specialization,
  }) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.registerTeacher(
        email: email,
        password: password,
        fullName: fullName,
        hourlyRate: hourlyRate,
        phone: phone,
        specialization: specialization,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }
}
