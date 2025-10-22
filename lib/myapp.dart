
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/lesson_repository.dart';
import 'data/repositories/user_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';

class VocalisApp extends StatelessWidget {
  const VocalisApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => LessonRepository()),
        RepositoryProvider(create: (context) => UserRepository()),
      ],

      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
            ),
          ),
        ],

        child: MaterialApp(

          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          // ---------------------------------------------------

          //
          title: 'Vocalis',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,

          // --- PUNTO DE ENTRADA DE LA APP ---
          // Reemplazamos 'Home()' por la pantalla de inicio de Vocalis
          home: const LoginScreen(),
        ),
      ),
    );
  }
}