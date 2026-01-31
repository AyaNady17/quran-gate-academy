import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_gate_academy/core/services/permission_service.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';
import 'package:quran_gate_academy/features/auth/presentation/pages/login_page.dart';
import 'package:quran_gate_academy/features/auth/presentation/pages/register_page.dart';
import 'package:quran_gate_academy/features/auth/presentation/pages/unauthorized_page.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/pages/teacher_dashboard_page.dart';
import 'package:quran_gate_academy/features/schedule/presentation/pages/schedule_page.dart';
import 'package:quran_gate_academy/features/students/presentation/pages/students_page.dart';
import 'package:quran_gate_academy/features/library/presentation/pages/library_page.dart';
import 'package:quran_gate_academy/features/tasks/presentation/pages/tasks_page.dart';
import 'package:quran_gate_academy/features/sessions/presentation/pages/sessions_page.dart';
import 'package:quran_gate_academy/features/sessions/presentation/pages/session_form_page_enhanced.dart';
import 'package:quran_gate_academy/features/teachers/presentation/pages/teachers_page.dart';
import 'package:quran_gate_academy/features/teachers/presentation/pages/teacher_form_page.dart';
import 'package:quran_gate_academy/features/availability/presentation/pages/availability_page.dart';

/// Application routing configuration with role-based access control
class AppRouter {
  // Route constants
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String dashboardRoute = '/';
  static const String scheduleRoute = '/schedule';
  static const String studentsRoute = '/students';
  static const String libraryRoute = '/library';
  static const String tasksRoute = '/tasks';
  static const String sessionsRoute = '/sessions';
  static const String teachersRoute = '/teachers';
  static const String availabilityRoute = '/availability';
  static const String unauthorizedRoute = '/unauthorized';

  /// Create router with authentication and role-based guards
  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: dashboardRoute,
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authCubit.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final currentPath = state.uri.path;

        // Define public routes that don't require authentication
        final isAuthRoute = currentPath == loginRoute ||
                           currentPath == registerRoute;

        // Redirect to login if not authenticated and not on auth route
        if (!isAuthenticated && !isAuthRoute) {
          return loginRoute;
        }

        // Redirect to dashboard if authenticated and on auth route
        if (isAuthenticated && isAuthRoute) {
          return dashboardRoute;
        }

        // Check role-based permissions for authenticated users
        if (authState is AuthAuthenticated) {
          final user = authState.user;

          // Skip permission check for unauthorized route itself
          if (currentPath == unauthorizedRoute) {
            return null;
          }

          // Check if user can access the route
          if (!PermissionService.canAccessRoute(user, currentPath)) {
            return unauthorizedRoute;
          }
        }

        // No redirect needed
        return null;
      },
      routes: [
        // ============================================
        // Public Routes (No Authentication Required)
        // ============================================
        GoRoute(
          path: loginRoute,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: registerRoute,
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),

        // ============================================
        // Protected Routes (Authentication Required)
        // ============================================

        // Dashboard - Role-based builder
        GoRoute(
          path: dashboardRoute,
          name: 'dashboard',
          builder: (context, state) {
            // Return role-specific dashboard based on user role
            final authState = context.read<AuthCubit>().state;
            if (authState is AuthAuthenticated) {
              return PermissionService.isAdmin(authState.user)
                  ? const AdminDashboardPage()
                  : const TeacherDashboardPage();
            }
            // Fallback to login (should not happen due to redirect logic)
            return const LoginPage();
          },
        ),

        // Schedule
        GoRoute(
          path: scheduleRoute,
          name: 'schedule',
          builder: (context, state) => const SchedulePage(),
        ),

        // Students
        GoRoute(
          path: studentsRoute,
          name: 'students',
          builder: (context, state) => const StudentsPage(),
        ),

        // Library
        GoRoute(
          path: libraryRoute,
          name: 'library',
          builder: (context, state) => const LibraryPage(),
        ),

        // Tasks
        GoRoute(
          path: tasksRoute,
          name: 'tasks',
          builder: (context, state) => const TasksPage(),
        ),

        // ============================================
        // Admin-Only Routes
        // ============================================

        // Sessions Management
        GoRoute(
          path: sessionsRoute,
          name: 'sessions',
          builder: (context, state) => const SessionsPage(),
        ),
        GoRoute(
          path: '$sessionsRoute/create',
          name: 'session-create',
          builder: (context, state) => const SessionFormPageEnhanced(),
        ),
        GoRoute(
          path: '$sessionsRoute/edit/:id',
          name: 'session-edit',
          builder: (context, state) {
            final sessionId = state.pathParameters['id'];
            return SessionFormPageEnhanced(sessionId: sessionId);
          },
        ),

        // Teacher Management
        GoRoute(
          path: teachersRoute,
          name: 'teachers',
          builder: (context, state) => const TeachersPage(),
        ),
        GoRoute(
          path: '$teachersRoute/create',
          name: 'teacher-create',
          builder: (context, state) => const TeacherFormPage(),
        ),
        GoRoute(
          path: '$teachersRoute/edit/:id',
          name: 'teacher-edit',
          builder: (context, state) {
            final teacherId = state.pathParameters['id'];
            return TeacherFormPage(teacherId: teacherId);
          },
        ),

        // ============================================
        // Teacher-Only Routes
        // ============================================

        // Availability Management
        GoRoute(
          path: availabilityRoute,
          name: 'availability',
          builder: (context, state) => const AvailabilityPage(),
        ),

        // ============================================
        // Error Routes
        // ============================================

        // Unauthorized Access
        GoRoute(
          path: unauthorizedRoute,
          name: 'unauthorized',
          builder: (context, state) => const UnauthorizedPage(),
        ),
      ],

      // Error handling
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(state.uri.path),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(dashboardRoute),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper class to refresh GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
