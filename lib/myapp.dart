import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/api/dio_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/lesson_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/exercise_repository.dart';
import 'data/repositories/progression_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/progression/progression_bloc.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';

class VocalisApp extends StatefulWidget {
  const VocalisApp({super.key});

  @override
  State<VocalisApp> createState() => _VocalisAppState();
}

class _VocalisAppState extends State<VocalisApp> {
  AuthBloc? _authBloc;

  @override
  void initState() {
    super.initState();
    // Configuramos el callback para cuando el token expire
    DioClient.onTokenExpired = _handleTokenExpired;
  }

  void _handleTokenExpired() {
    // Cuando el token expira, disparamos el evento en el AuthBloc
    if (_authBloc != null) {
      _authBloc!.add(TokenExpired());
    }
  }

  @override
  void dispose() {
    DioClient.onTokenExpired = null;
    super.dispose();
  }

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
            create: (context) {
              final authBloc = AuthBloc(
                authRepository: RepositoryProvider.of<AuthRepository>(context),
                progressionRepository: RepositoryProvider.of<ProgressionRepository>(context),
                progressionBloc: BlocProvider.of<ProgressionBloc>(context),
              )..add(AppStarted());
              
              // Guardamos la referencia del AuthBloc
              _authBloc = authBloc;
              return authBloc;
            },
          ),
        ],
        child: const _AppContent(),
      ),
    );
  }
}

class _AppContent extends StatelessWidget {
  const _AppContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Cuando el token expire, redirigir al login
        if (state is AuthFailure && 
            state.error == "Tu sesión ha expirado. Por favor, inicia sesión nuevamente.") {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
          
          // Mostrar mensaje al usuario
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tu sesión ha expirado. Por favor, inicia sesión nuevamente.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
        child: MaterialApp(
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          title: 'Vocalis',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system, // Detecta automáticamente modo claro/oscuro del sistema
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        ),
    );
  }
}