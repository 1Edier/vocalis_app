import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:vocalis/data/models/progression_map_model.dart';
import 'package:vocalis/presentation/bloc/progression/progression_bloc.dart';
import 'package:vocalis/presentation/screens/exercise/exercise_screen.dart';
import '../../data/models/user_model.dart';
import '../bloc/auth/auth_bloc.dart';
import '../widgets/widgets.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  final UserModel user;
  final int initialIndex;

  const MainScaffold({super.key, required this.user, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with TickerProviderStateMixin {
  late int _selectedIndex;
  late final List<Widget> _widgetOptions;
  late final AnimationController _lottieController;
  Future<LottieComposition>? _composition;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    _widgetOptions = [
      const HomeScreen(),
      const SizedBox.shrink(), // Placeholder para el botón de atajo (índice 1)
      ProfileScreen(user: widget.user),
    ];

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
    if (index == 1) {
      // Botón de atajo a "Metas"
      final progressionState = context.read<ProgressionBloc>().state;
      if (progressionState is ProgressionLoadSuccess) {
        ExerciseProgress? nextExercise;
        for (final category in progressionState.progressionMap.categories) {
          for (final exercise in category.exercises) {
            if (exercise.status == 'available') {
              nextExercise = exercise;
              break;
            }
          }
          if (nextExercise != null) break;
        }

        if (nextExercise != null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ExerciseScreen(exerciseId: nextExercise!.exerciseId)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Felicidades! Has completado todos los ejercicios.')),
          );
        }
      }
      return;
    }

    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Stack(
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
            body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
            bottomNavigationBar: GlassBottomNavBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: VocalisNavItems.mainItems,
            ),
          ),
        ],
      ),
    );
  }
}
