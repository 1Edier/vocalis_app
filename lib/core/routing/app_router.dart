// lib/core/routing/app_router.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vocalis/data/models/user_model.dart';
import 'package:vocalis/presentation/bloc/auth/auth_bloc.dart';
import 'package:vocalis/presentation/screens/auth/login_screen.dart';
import 'package:vocalis/presentation/screens/auth/signup_screen.dart';
import 'package:vocalis/presentation/screens/exercise/exercise_screen.dart';
import 'package:vocalis/presentation/screens/home/home_screen.dart';
import 'package:vocalis/presentation/screens/main_scaffold.dart';
import 'package:vocalis/presentation/screens/profile/profile_screen.dart';
import 'package:vocalis/presentation/screens/splash_screen.dart';
import 'app_routes.dart';

// Una clave para el navegador raíz
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
// Una clave para el navegador de la Shell (para la barra de navegación inferior)
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      // --- Shell principal de la aplicación con BottomNavigationBar ---
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          final authState = context.watch<AuthBloc>().state;
          if (authState is AuthSuccess) {
            return MainScaffold(user: authState.user, child: child);
          }
          return const Scaffold(body: Center(child: Text("Redirigiendo...")));
        },
        routes: [
          GoRoute(
            path: AppRoutes.homeMap,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.homeProfile,
            builder: (context, state) {
              final authState = context.read<AuthBloc>().state;
              UserModel? user = (authState is AuthSuccess) ? authState.user : null;
              return ProfileScreen(user: user!);
            },
          ),
        ],
      ),
      // --- Ruta fuera de la shell principal (cubrirá la barra de navegación inferior) ---
      GoRoute(
        // --- CORRECCIÓN ---
        // Al especificar el parentNavigatorKey, le decimos a GoRouter que esta ruta
        // debe usar el navegador raíz, ignorando la ShellRoute.
        // Esto hace que se muestre por encima de todo, sin duplicar la barra de navegación.
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.exercise,
        builder: (context, state) {
          final exerciseId = state.pathParameters['exerciseId']!;
          return ExerciseScreen(exerciseId: exerciseId);
        },
      ),
    ],
    redirect: (context, state) {
      final authState = authBloc.state;
      final currentLocation = state.uri.toString();

      if (authState is AuthInitial || authState is AuthLoading) {
        return currentLocation == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final isAuthenticated = authState is AuthSuccess;
      final isAuthScreen =
          currentLocation == AppRoutes.login || currentLocation == AppRoutes.signup;
      final isSplashScreen = currentLocation == AppRoutes.splash;

      if (isAuthenticated && (isAuthScreen || isSplashScreen)) {
        return AppRoutes.homeMap;
      }

      if (!isAuthenticated && !isAuthScreen) {
        return AppRoutes.login;
      }

      return null;
    },
  );
}

/// Una clase para convertir un Stream en un Listenable para el refreshListenable de GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}