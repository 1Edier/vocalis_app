import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/lesson_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/exercise_repository.dart';
import 'data/repositories/progression_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/progression/progression_bloc.dart';
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
          // Creamos el ProgressionBloc primero para que esté disponible
          BlocProvider(
            create: (context) => ProgressionBloc(
              progressionRepository: RepositoryProvider.of<ProgressionRepository>(context),
            ),
          ),
          // Creamos el AuthBloc y le pasamos el ProgressionBloc
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
              progressionRepository: RepositoryProvider.of<ProgressionRepository>(context),
              progressionBloc: BlocProvider.of<ProgressionBloc>(context),
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