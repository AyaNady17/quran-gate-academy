import 'package:appwrite/appwrite.dart';

/// Application configuration and constants
class AppConfig {
  // Appwrite Configuration
  static const String appwriteEndpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String appwriteProjectId = '697cff53000c636e00c8';
  static const String appwriteDatabaseId = 'quran_gate_db';

  // Collection IDs
  static const String usersCollectionId = 'users';
  static const String studentsCollectionId = 'students';
  static const String coursesCollectionId = 'courses';
  static const String plansCollectionId = 'plans';
  static const String classSessionsCollectionId = 'class_sessions';
  static const String teacherAvailabilityCollectionId = 'teacher_availability';
  static const String rescheduleRequestsCollectionId = 'reschedule_requests';
  static const String salaryRecordsCollectionId = 'salary_records';
  static const String tasksCollectionId = 'tasks';

  // Appwrite client instance
  static late Client client;
  static late Account account;
  static late Databases databases;
  static late Storage storage;

  /// Initialize Appwrite SDK
  static Future<void> initialize() async {
    client = Client()
        .setEndpoint(appwriteEndpoint)
        .setProject(appwriteProjectId);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';

  // Session Statuses
  static const String sessionStatusScheduled = 'scheduled';
  static const String sessionStatusCompleted = 'completed';
  static const String sessionStatusAbsent = 'absent';
  static const String sessionStatusStudentCancel = 'student_cancel';
  static const String sessionStatusTeacherCancel = 'teacher_cancel';

  // Task Statuses
  static const String taskStatusPending = 'pending';
  static const String taskStatusInProgress = 'in_progress';
  static const String taskStatusCompleted = 'completed';
  static const String taskStatusOverdue = 'overdue';

  // Days of Week
  static const List<String> daysOfWeek = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];
}
