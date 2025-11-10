import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Imports para la arquitectura Vocalis
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/lesson_repository.dart';
import 'data/repositories/user_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/screens/splash_screen.dart'; // Importamos la SplashScreen

// El nombre de la clase principal de la app, como en tu `main.dart`
class VocalisApp extends StatelessWidget {
  const VocalisApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Proveemos los Repositorios a toda la aplicación
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => LessonRepository()),
        RepositoryProvider(create: (context) => UserRepository()),
      ],
      // 2. Proveemos los BLoCs que sean necesarios globalmente
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
            )..add(AppStarted()), // Disparamos el evento para verificar la sesión al iniciar
          ),
        ],
        // 3. Construimos el MaterialApp con la configuración de DevicePreview
        child: MaterialApp(
          // --- CONFIGURACIÓN DE DEVICEREVIEW ---
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          // ------------------------------------

          // --- CONFIGURACIÓN DE VOCALIS ---
          title: 'Vocalis',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,

          // --- PUNTO DE ENTRADA DE LA APP ---
          // La SplashScreen decidirá a dónde navegar
          home: const SplashScreen(),
        ),
      ),
    );
  }
}