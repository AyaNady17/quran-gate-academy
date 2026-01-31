import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/router/app_router.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await configureDependencies();

  // Initialize Appwrite
  await AppConfig.initialize();

  runApp(const QuranGateAcademyApp());
}

class QuranGateAcademyApp extends StatelessWidget {
  const QuranGateAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AuthCubit>()..checkAuthStatus(),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Get AuthCubit to pass to router for authentication and role guards
          final authCubit = context.read<AuthCubit>();

          return MaterialApp.router(
            title: 'Quran Gate Academy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            routerConfig: AppRouter.createRouter(authCubit),
          );
        },
      ),
    );
  }
}
