import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Imports para la arquitectura Vocalis
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/lesson_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/exercise_repository.dart';
import 'data/repositories/progression_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/screens/splash_screen.dart';

class VocalisApp extends StatelessWidget {
  const VocalisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => LessonRepository()),
        RepositoryProvider(create: (context) => UserRepository()),
        RepositoryProvider(create: (context) => ExerciseRepository()),
        RepositoryProvider(create: (context) => ProgressionRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
              // Inyectamos ambos repositorios al AuthBloc
              progressionRepository: RepositoryProvider.of<ProgressionRepository>(context),
            )..add(AppStarted()),
          ),
        ],
        child: MaterialApp(
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          title: 'Vocalis',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}