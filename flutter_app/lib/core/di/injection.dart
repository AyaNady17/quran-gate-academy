import 'package:get_it/get_it.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';
import 'package:quran_gate_academy/core/models/user_model.dart';
import 'package:quran_gate_academy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:quran_gate_academy/features/auth/data/services/auth_service.dart';
import 'package:quran_gate_academy/features/auth/domain/repositories/auth_repository.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/availability/data/repositories/availability_repository_impl.dart';
import 'package:quran_gate_academy/features/availability/data/services/availability_service.dart';
import 'package:quran_gate_academy/features/availability/domain/repositories/availability_repository.dart';
import 'package:quran_gate_academy/features/availability/presentation/cubit/availability_cubit.dart';
import 'package:quran_gate_academy/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:quran_gate_academy/features/dashboard/data/services/dashboard_service.dart';
import 'package:quran_gate_academy/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/admin_dashboard_cubit.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/teacher_dashboard_cubit.dart';
import 'package:quran_gate_academy/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:quran_gate_academy/features/schedule/data/services/schedule_service.dart';
import 'package:quran_gate_academy/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:quran_gate_academy/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:quran_gate_academy/features/sessions/data/repositories/session_repository_impl.dart';
import 'package:quran_gate_academy/features/sessions/data/services/session_service.dart';
import 'package:quran_gate_academy/features/sessions/domain/repositories/session_repository.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_cubit.dart';
import 'package:quran_gate_academy/features/sessions/data/repositories/session_report_repository_impl.dart';
import 'package:quran_gate_academy/features/sessions/data/services/session_report_service.dart';
import 'package:quran_gate_academy/features/sessions/domain/repositories/session_report_repository.dart';
import 'package:quran_gate_academy/features/sessions/presentation/cubit/session_report_cubit.dart';
import 'package:quran_gate_academy/features/students/data/repositories/student_repository_impl.dart';
import 'package:quran_gate_academy/features/students/data/services/student_service.dart';
import 'package:quran_gate_academy/features/students/domain/repositories/student_repository.dart';
import 'package:quran_gate_academy/features/students/presentation/cubit/student_cubit.dart';
import 'package:quran_gate_academy/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:quran_gate_academy/features/tasks/data/services/task_service.dart';
import 'package:quran_gate_academy/features/tasks/domain/repositories/task_repository.dart';
import 'package:quran_gate_academy/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:quran_gate_academy/features/teachers/data/repositories/teacher_repository_impl.dart';
import 'package:quran_gate_academy/features/teachers/data/services/teacher_service.dart';
import 'package:quran_gate_academy/features/teachers/domain/repositories/teacher_repository.dart';
import 'package:quran_gate_academy/features/teachers/presentation/cubit/teacher_cubit.dart';
import 'package:quran_gate_academy/features/dashboard/data/repositories/student_dashboard_repository_impl.dart';
import 'package:quran_gate_academy/features/dashboard/data/services/student_dashboard_service.dart';
import 'package:quran_gate_academy/features/dashboard/domain/repositories/student_dashboard_repository.dart';
import 'package:quran_gate_academy/features/dashboard/presentation/cubit/student_dashboard_cubit.dart';
import 'package:quran_gate_academy/features/learning_materials/data/repositories/learning_material_repository_impl.dart';
import 'package:quran_gate_academy/features/learning_materials/data/services/learning_material_service.dart';
import 'package:quran_gate_academy/features/learning_materials/domain/repositories/learning_material_repository.dart';
import 'package:quran_gate_academy/features/learning_materials/presentation/cubit/learning_material_cubit.dart';

final getIt = GetIt.instance;

/// Configure dependency injection
Future<void> configureDependencies() async {
  // Services
  getIt.registerLazySingleton(() => AuthService(
        account: AppConfig.account,
        databases: AppConfig.databases,
      ));

  getIt.registerLazySingleton(() => DashboardService(
        databases: AppConfig.databases,
      ));

  getIt.registerLazySingleton(() => ScheduleService(
        databases: AppConfig.databases,
      ));

  getIt.registerLazySingleton(() => StudentService(
        databases: AppConfig.databases,
        account: AppConfig.account,
      ));

  getIt.registerLazySingleton(() => TaskService(
        databases: AppConfig.databases,
      ));

  getIt.registerLazySingleton(() => SessionService(
        databases: AppConfig.databases,
      ));

  getIt.registerLazySingleton(() => TeacherService(
        account: AppConfig.account,
        databases: AppConfig.databases,
      ));

  getIt.registerLazySingleton(() => AvailabilityService(
        databases: AppConfig.databases,
      ));

  getIt.registerLazySingleton(() => StudentDashboardService(
        databases: AppConfig.databases,
      ));

  getIt.registerLazySingleton(() => LearningMaterialService(
        databases: AppConfig.databases,
        storage: AppConfig.storage,
      ));

  getIt.registerLazySingleton(() => SessionReportService(
        databases: AppConfig.databases,
      ));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authService: getIt()),
  );

  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(dashboardService: getIt()),
  );

  getIt.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(scheduleService: getIt()),
  );

  getIt.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(studentService: getIt()),
  );

  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(taskService: getIt()),
  );

  getIt.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sessionService: getIt()),
  );

  getIt.registerLazySingleton<TeacherRepository>(
    () => TeacherRepositoryImpl(teacherService: getIt()),
  );

  getIt.registerLazySingleton<AvailabilityRepository>(
    () => AvailabilityRepositoryImpl(availabilityService: getIt()),
  );

  getIt.registerLazySingleton<StudentDashboardRepository>(
    () => StudentDashboardRepositoryImpl(studentDashboardService: getIt()),
  );

  getIt.registerLazySingleton<LearningMaterialRepository>(
    () => LearningMaterialRepositoryImpl(learningMaterialService: getIt()),
  );

  getIt.registerLazySingleton<SessionReportRepository>(
    () => SessionReportRepositoryImpl(sessionReportService: getIt()),
  );

  // Cubits
  getIt.registerFactory(() => AuthCubit(authRepository: getIt()));
  getIt.registerFactory(() => DashboardCubit(dashboardRepository: getIt()));
  getIt.registerFactory(() => AdminDashboardCubit(
        dashboardRepository: getIt(),
        teacherRepository: getIt(),
        studentRepository: getIt(),
      ));
  getIt.registerFactory(() => TeacherDashboardCubit(
        dashboardRepository: getIt(),
        studentRepository: getIt(),
      ));
  getIt.registerFactory(() => ScheduleCubit(scheduleRepository: getIt()));
  getIt.registerFactory(() => StudentCubit(studentRepository: getIt()));
  getIt.registerFactory(() => TaskCubit(taskRepository: getIt()));
  getIt.registerFactory(() => TeacherCubit(teacherRepository: getIt()));
  getIt.registerFactory(
      () => AvailabilityCubit(availabilityRepository: getIt()));

  getIt.registerFactory(() => StudentDashboardCubit(
        studentDashboardRepository: getIt(),
        teacherRepository: getIt(),
      ));

  getIt.registerFactory(() => LearningMaterialCubit(
        learningMaterialRepository: getIt(),
      ));

  getIt.registerFactory(() => SessionReportCubit(
        sessionReportRepository: getIt(),
      ));

  // SessionCubit with user parameter for RBAC
  getIt.registerFactoryParam<SessionCubit, UserModel, void>(
    (user, _) => SessionCubit(
      sessionRepository: getIt(),
      teacherRepository: getIt(),
      studentRepository: getIt(),
      currentUser: user,
    ),
  );
}
