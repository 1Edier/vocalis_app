// lib/presentation/screens/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:vocalis/core/routing/app_routes.dart';
import 'package:vocalis/data/models/progression_map_model.dart';
import 'package:vocalis/presentation/bloc/progression/progression_bloc.dart';
import '../../data/models/user_model.dart';
import '../widgets/widgets.dart';

class MainScaffold extends StatefulWidget {
  final UserModel user;
  final Widget child; // El contenido de la ShellRoute

  const MainScaffold({super.key, required this.user, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  Future<LottieComposition>? _composition;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _composition = AssetLottie('assets/lottie/space_background.json').load();
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _lottieController.reset();
        _lottieController.forward();
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _calculateSelectedIndex(context)) return;

    switch (index) {
      case 0:
        context.go(AppRoutes.homeMap);
        break;
      case 1:
      // Botón de atajo a "Metas"
        final progressionState = context.read<ProgressionBloc>().state;
        if (progressionState is ProgressionLoadSuccess) {

          // --- CORRECCIÓN LÓGICA ---
          // Usamos bucles for para encontrar el primer ejercicio disponible de forma segura.
          ExerciseProgress? nextExercise;
          for (final category in progressionState.progressionMap.categories) {
            for (final exercise in category.exercises) {
              if (exercise.status == 'available') {
                nextExercise = exercise;
                break; // Salimos del bucle interior
              }
            }
            if (nextExercise != null) {
              break; // Salimos del bucle exterior
            }
          }

          if (nextExercise != null) {
            context.push(AppRoutes.exerciseDetail(nextExercise.exerciseId));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Felicidades! Has completado todos los ejercicios.')),
            );
          }
        }
        break;
      case 2:
        context.go(AppRoutes.homeProfile);
        break;
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    // --- CORRECCIÓN API GoRouter ---
    // Usamos GoRouterState.of(context).uri.toString() para obtener la ruta actual.
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith(AppRoutes.homeMap)) {
      return 0;
    }
    if (location.startsWith(AppRoutes.homeProfile)) {
      return 2;
    }
    // Por defecto, selecciona home si la ubicación no es una pestaña principal
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: FutureBuilder<LottieComposition>(
            future: _composition,
            builder: (context, snapshot) {
              var composition = snapshot.data;
              if (composition != null) {
                _lottieController.duration = composition.duration;
                if (!_lottieController.isAnimating) {
                  _lottieController.forward();
                }
                return Lottie(
                  composition: composition,
                  controller: _lottieController,
                  fit: BoxFit.cover,
                );
              } else {
                return Container(color: const Color(0xFF2E2A4F));
              }
            },
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: widget.child, // El hijo de la ShellRoute se muestra aquí
          bottomNavigationBar: GlassBottomNavBar(
            currentIndex: _calculateSelectedIndex(context),
            onTap: _onItemTapped,
            items: VocalisNavItems.mainItems,
          ),
        ),
      ],
    );
  }
}