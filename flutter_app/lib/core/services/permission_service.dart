import 'package:quran_gate_academy/core/config/app_config.dart';
import 'package:quran_gate_academy/core/models/user_model.dart';
import 'package:quran_gate_academy/core/router/app_router.dart';

/// Centralized permission service for role-based access control
class PermissionService {
  // ============================================
  // Role Checks
  // ============================================

  /// Check if user is an admin
  static bool isAdmin(UserModel user) => user.role == AppConfig.roleAdmin;

  /// Check if user is a teacher
  static bool isTeacher(UserModel user) => user.role == AppConfig.roleTeacher;

  /// Check if user is a student
  static bool isStudent(UserModel user) => user.role == AppConfig.roleStudent;

  // ============================================
  // Route Permissions
  // ============================================

  /// Define routes accessible to teachers
  static final List<String> _teacherAllowedRoutes = [
    AppRouter.dashboardRoute,
    AppRouter.scheduleRoute,
    AppRouter.studentsRoute,
    AppRouter.libraryRoute,
    AppRouter.tasksRoute,
    '/availability', // Teacher-only availability management
    '/my-sessions', // Teacher-only sessions view
    '/chat',
    '/policy',
  ];

  /// Define routes accessible to students
  static final List<String> _studentAllowedRoutes = [
    AppRouter.dashboardRoute,
    AppRouter.mySessionsRoute,
    '/learning-materials', // Student learning materials library
    '/profile', // Student profile page
    '/chat',
    '/policy',
  ];

  /// Check if user can access a specific route
  static bool canAccessRoute(UserModel user, String route) {
    // Admins can access all routes
    if (isAdmin(user)) return true;

    // Teachers can only access allowed routes
    if (isTeacher(user)) {
      // Check exact route or route prefix
      return _teacherAllowedRoutes.any((allowedRoute) {
        return route == allowedRoute || route.startsWith('$allowedRoute/');
      });
    }

    // Students can only access allowed routes
    if (isStudent(user)) {
      // Check exact route or route prefix
      return _studentAllowedRoutes.any((allowedRoute) {
        return route == allowedRoute || route.startsWith('$allowedRoute/');
      });
    }

    // Default: deny access
    return false;
  }

  // ============================================
  // Feature Permissions - Admin
  // ============================================

  /// Can manage teachers (create, edit, delete)
  static bool canManageTeachers(UserModel user) => isAdmin(user);

  /// Can manage students (create, edit, delete)
  static bool canManageStudents(UserModel user) => isAdmin(user);

  /// Can create sessions
  static bool canCreateSessions(UserModel user) => isAdmin(user);

  /// Can edit any session
  static bool canEditAnySessions(UserModel user) => isAdmin(user);

  /// Can delete sessions
  static bool canDeleteSessions(UserModel user) => isAdmin(user);

  /// Can approve or reject reschedule requests
  static bool canApproveReschedules(UserModel user) => isAdmin(user);

  /// Can view all data across the system
  static bool canViewAllData(UserModel user) => isAdmin(user);

  /// Can view system-wide reports and analytics
  static bool canViewSystemReports(UserModel user) => isAdmin(user);

  // ============================================
  // Feature Permissions - Teacher
  // ============================================

  /// Can update own sessions (mark complete, update notes)
  static bool canUpdateOwnSessions(UserModel user) =>
      isTeacher(user) || isAdmin(user);

  /// Can request reschedule (but not approve)
  static bool canRequestReschedule(UserModel user) => isTeacher(user);

  /// Can manage own availability time slots
  static bool canManageAvailability(UserModel user) => isTeacher(user);

  /// Can view own data (sessions, students, stats)
  static bool canViewOwnData(UserModel user) =>
      isTeacher(user) || isAdmin(user);

  /// Can view own salary and attendance statistics
  static bool canViewOwnStats(UserModel user) =>
      isTeacher(user) || isAdmin(user);

  // ============================================
  // Data Access Permissions
  // ============================================

  /// Check if user can access a specific teacher's data
  static bool canAccessTeacherData(UserModel user, String teacherId) {
    // Admins can access any teacher's data
    if (isAdmin(user)) return true;

    // Teachers can only access their own data
    if (isTeacher(user)) return user.id == teacherId;

    return false;
  }

  /// Check if user can access a specific student's data
  static bool canAccessStudentData(UserModel user, String studentId) {
    // Admins can access any student's data
    if (isAdmin(user)) return true;

    // Teachers can access their assigned students
    // Note: This requires checking if student is assigned to teacher
    // Implementation depends on student-teacher relationship
    if (isTeacher(user)) {
      // TODO: Implement student-teacher assignment check
      return true; // Temporary: allow access
    }

    // Students can only access their own linked data
    if (isStudent(user) && user.linkedStudentId != null) {
      return user.linkedStudentId == studentId;
    }

    return false;
  }

  /// Check if user can access a specific session
  static bool canAccessSession(
    UserModel user,
    String sessionTeacherId, [
    String? sessionStudentId,
  ]) {
    // Admins can access any session
    if (isAdmin(user)) return true;

    // Teachers can only access their own sessions
    if (isTeacher(user)) return user.id == sessionTeacherId;

    // Students can only access sessions where they are the student
    if (isStudent(user) &&
        user.linkedStudentId != null &&
        sessionStudentId != null) {
      return user.linkedStudentId == sessionStudentId;
    }

    return false;
  }

  // ============================================
  // Session Operation Permissions
  // ============================================

  /// Check if user can mark a session as completed
  static bool canMarkSessionComplete(UserModel user, String sessionTeacherId) {
    // Admins can mark any session complete
    if (isAdmin(user)) return true;

    // Teachers can only mark their own sessions complete
    if (isTeacher(user)) return user.id == sessionTeacherId;

    return false;
  }

  /// Check if user can cancel a session
  static bool canCancelSession(UserModel user, String sessionTeacherId) {
    // Admins can cancel any session
    if (isAdmin(user)) return true;

    // Teachers can request to cancel their own sessions
    if (isTeacher(user)) return user.id == sessionTeacherId;

    return false;
  }

  // ============================================
  // Student Permissions
  // ============================================

  /// Can view own sessions (students read-only)
  static bool canViewOwnSessions(UserModel user) =>
      isStudent(user) || isTeacher(user) || isAdmin(user);

  /// Can view learning materials
  static bool canViewLearningMaterials(UserModel user) => true; // All roles

  /// Can edit session status (students cannot)
  static bool canEditSessionStatus(UserModel user) =>
      isTeacher(user) || isAdmin(user);

  /// Can manage learning materials (upload, edit, delete)
  static bool canManageLearningMaterials(UserModel user) => isAdmin(user);

  /// Can view session notes (students only after completion)
  static bool canViewSessionNotes(
    UserModel user,
    String sessionStatus,
    String? sessionStudentId,
  ) {
    // Admins and teachers can always view notes
    if (isAdmin(user) || isTeacher(user)) return true;

    // Students can only view notes after session completion
    if (isStudent(user) &&
        user.linkedStudentId != null &&
        sessionStudentId != null) {
      return user.linkedStudentId == sessionStudentId &&
          sessionStatus == AppConfig.sessionStatusCompleted;
    }

    return false;
  }
}
