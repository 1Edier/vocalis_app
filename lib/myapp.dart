// lib/myapp.dart
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocalis/core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/api/dio_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/lesson_repository.dart';
import 'data/repositories/progression_repository.dart';
import 'data/repositories/user_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/progression/progression_bloc.dart';

class VocalisApp extends StatefulWidget {
  const VocalisApp({super.key});

  @override
  State<VocalisApp> createState() => _VocalisAppState();
}

class _VocalisAppState extends State<VocalisApp> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;
  // Guardamos las instancias para proveerlas consistentemente
  late final AuthRepository _authRepository;
  late final ProgressionRepository _progressionRepository;
  late final ProgressionBloc _progressionBloc;

  @override
  void initState() {
    super.initState();

    // 1. Creamos las instancias de los repositorios y Blocs
    _authRepository = AuthRepository();
    _progressionRepository = ProgressionRepository();
    _progressionBloc = ProgressionBloc(progressionRepository: _progressionRepository);

    // Las dependencias se pasan en el constructor.
    _authBloc = AuthBloc(
      authRepository: _authRepository,
      progressionRepository: _progressionRepository,
      progressionBloc: _progressionBloc,
    )..add(AppStarted());

    // 2. Creamos el router, pasándole el AuthBloc
    _appRouter = AppRouter(authBloc: _authBloc);

    // 3. Configuramos el callback de DioClient
    DioClient.onTokenExpired = () {
      _authBloc.add(TokenExpired());
    };
  }

  @override
  void dispose() {
    DioClient.onTokenExpired = null;
    _authBloc.close();
    _progressionBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4. Proveemos las instancias ya creadas al árbol de widgets
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _progressionRepository),
        // Proveemos los otros repositorios que no dependen de estado
        RepositoryProvider(create: (context) => LessonRepository()),
        RepositoryProvider(create: (context) => UserRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _progressionBloc),
          BlocProvider.value(value: _authBloc),
        ],
        child: MaterialApp.router(
          routerConfig: _appRouter.router,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          title: "Vocalis",
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
