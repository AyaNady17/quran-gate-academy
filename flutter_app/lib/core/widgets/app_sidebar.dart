import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_gate_academy/core/router/app_router.dart';
import 'package:quran_gate_academy/core/services/permission_service.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';

/// Application sidebar navigation menu
class AppSidebar extends StatelessWidget {
  final String currentRoute;

  const AppSidebar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // Determine user role from auth state
        final isAdmin = authState is AuthAuthenticated &&
            PermissionService.isAdmin(authState.user);
        final isTeacher = authState is AuthAuthenticated &&
            PermissionService.isTeacher(authState.user);

        return _buildSidebar(context, isAdmin, isTeacher);
      },
    );
  }

  Widget _buildSidebar(BuildContext context, bool isAdmin, bool isTeacher) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Icon(
                  Icons.school,
                  size: 32,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quran Gate',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Academy',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _MenuItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  route: AppRouter.dashboardRoute,
                  isActive: currentRoute == AppRouter.dashboardRoute,
                  onTap: () => context.go(AppRouter.dashboardRoute),
                ),
                _MenuItem(
                  icon: Icons.chat_outlined,
                  label: 'Chat',
                  route: '/chat',
                  isActive: currentRoute == '/chat',
                  onTap: () {
                    // TODO: Implement chat
                  },
                ),
                _MenuItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Schedule',
                  route: AppRouter.scheduleRoute,
                  isActive: currentRoute == AppRouter.scheduleRoute,
                  onTap: () => context.go(AppRouter.scheduleRoute),
                ),
                _MenuItem(
                  icon: Icons.people_outline,
                  label: 'Students',
                  route: AppRouter.studentsRoute,
                  isActive: currentRoute == AppRouter.studentsRoute,
                  onTap: () => context.go(AppRouter.studentsRoute),
                ),
                _MenuItem(
                  icon: Icons.library_books_outlined,
                  label: 'Library',
                  route: AppRouter.libraryRoute,
                  isActive: currentRoute == AppRouter.libraryRoute,
                  onTap: () => context.go(AppRouter.libraryRoute),
                ),
                _MenuItem(
                  icon: Icons.task_outlined,
                  label: 'Tasks',
                  route: AppRouter.tasksRoute,
                  isActive: currentRoute == AppRouter.tasksRoute,
                  badge: 'New',
                  onTap: () => context.go(AppRouter.tasksRoute),
                ),

                // Admin-only menu items
                if (isAdmin) ...[
                  _MenuItem(
                    icon: Icons.event_note_outlined,
                    label: 'Sessions',
                    route: AppRouter.sessionsRoute,
                    isActive: currentRoute == AppRouter.sessionsRoute,
                    onTap: () => context.go(AppRouter.sessionsRoute),
                  ),
                  _MenuItem(
                    icon: Icons.person_outline,
                    label: 'Teachers',
                    route: AppRouter.teachersRoute,
                    isActive: currentRoute == AppRouter.teachersRoute,
                    onTap: () => context.go(AppRouter.teachersRoute),
                  ),
                ],

                // Teacher-only menu items
                if (isTeacher) ...[
                  _MenuItem(
                    icon: Icons.event_note_outlined,
                    label: 'My Sessions',
                    route: AppRouter.mySessionsRoute,
                    isActive: currentRoute == AppRouter.mySessionsRoute,
                    onTap: () => context.go(AppRouter.mySessionsRoute),
                  ),
                  _MenuItem(
                    icon: Icons.calendar_month_outlined,
                    label: 'Availability',
                    route: AppRouter.availabilityRoute,
                    isActive: currentRoute == AppRouter.availabilityRoute,
                    onTap: () => context.go(AppRouter.availabilityRoute),
                  ),
                ],

                _MenuItem(
                  icon: Icons.policy_outlined,
                  label: 'Policy',
                  route: '/policy',
                  isActive: currentRoute == '/policy',
                  onTap: () {
                    // TODO: Implement policy page
                  },
                ),
                Builder(
                  builder: (context) => _MenuItem(
                    icon: Icons.logout,
                    label: 'Log Out',
                    route: '/logout',
                    isActive: false,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _handleLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  /// Handle logout
  void _handleLogout(BuildContext context) async {
    try {
      await context.read<AuthCubit>().logout();
      if (context.mounted) {
        context.go(AppRouter.loginRoute);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final VoidCallback onTap;
  final String? badge;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isActive ? AppTheme.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? Colors.white : AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isActive
                              ? Colors.white
                              : AppTheme.textPrimaryColor,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
