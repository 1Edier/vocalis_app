import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/repositories/exercise_repository.dart';
import '../../bloc/lesson_detail/lesson_detail_bloc.dart';
import '../exercise/exercise_screen.dart';

class LessonDetailScreen extends StatelessWidget {
  final LessonCategory category;
  final int level;

  const LessonDetailScreen({
    super.key,
    required this.category,
    required this.level,
  });

  // --- NUEVA FUNCIÓN AUXILIAR ---
  // Esta función elige un icono temático basado en la categoría.
  IconData _getMainLevelIcon(LessonCategory category) {
    switch (category.title) {
      case 'Fonemas':
        return Icons.record_voice_over_rounded; // Icono de persona hablando/practicando
      case 'Ritmo':
        return Icons.music_note_rounded; // Icono de nota musical
      case 'Entonación':
        return Icons.graphic_eq_rounded; // Icono de ecualizador (ondas de sonido)
      default:
        return Icons.star_rounded; // Un icono por defecto si la categoría no coincide
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiCategory = category.title.toLowerCase().replaceAll('ó', 'o').replaceAll('á', 'a');

    return BlocProvider(
      create: (context) => LessonDetailBloc(
        exerciseRepository: ExerciseRepository(),
      )..add(FetchExercisesForLevel(category: apiCategory, level: level)),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(category.title),
              const SizedBox(width: 8),
              Icon(Icons.workspace_premium_rounded, color: Colors.orange[600], size: 20),
              Text(' 18', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
              const SizedBox(width: 16),
              const Icon(Icons.diamond_outlined, color: Colors.cyan, size: 20),
              Text(' 213', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
            ],
          ),
        ),
        body: BlocBuilder<LessonDetailBloc, LessonDetailState>(
          builder: (context, state) {
            if (state is LessonDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is LessonDetailLoadSuccess) {
              if (state.exercises.isEmpty) {
                return const Center(child: Text('No hay ejercicios para este nivel.'));
              }
              return _buildPathLayout(context, state.exercises);
            }
            if (state is LessonDetailLoadFailure) {
              return Center(child: Text(state.error));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildPathLayout(BuildContext context, List<ExerciseModel> exercises) {
    int completedExercises = 3;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          _buildMainLessonCard(context, level, completedExercises, exercises.length),
          const SizedBox(height: 32),
          _buildLessonRow(context, exercises, 0, 1, completedExercises),
          const SizedBox(height: 24),
          _buildLessonRow(context, exercises, 1, 2, completedExercises),
          const SizedBox(height: 24),
          _buildLessonRow(context, exercises, 3, 1, completedExercises),
          const SizedBox(height: 24),
          _buildLessonRow(context, exercises, 4, 2, completedExercises),
        ],
      ),
    );
  }

  Widget _buildLessonRow(BuildContext context, List<ExerciseModel> exercises, int startIndex, int count, int completedCount) {
    if (startIndex >= exercises.length) {
      return const SizedBox.shrink();
    }

    final exercisesForThisRow = exercises.skip(startIndex).take(count).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(exercisesForThisRow.length, (index) {
        final exerciseIndex = startIndex + index;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _LessonCircle(
            exercise: exercisesForThisRow[index],
            isLocked: exerciseIndex >= completedCount,
          ),
        );
      }),
    );
  }

  Widget _buildMainLessonCard(BuildContext context, int level, int completed, int total) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
      ),
      child: Column(
        children: [
          // --- CAMBIO PRINCIPAL: Se reemplaza Image.network por un Icon dinámico ---
          Icon(
            _getMainLevelIcon(category),
            size: 60,
            color: AppTheme.accentColor.withOpacity(0.8),
          ),
          const SizedBox(height: 12),
          Text('Lvl $level', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: total > 0 ? completed / total : 0,
            backgroundColor: Colors.grey[300],
            color: Colors.orange[600],
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 4),
          Text('$completed/$total', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

class _LessonCircle extends StatelessWidget {
  final ExerciseModel exercise;
  final bool isLocked;

  const _LessonCircle({
    required this.exercise,
    this.isLocked = false,
  });

  IconData _getIconForSubcategory(String subcategory) {
    if (subcategory.contains('afirmaciones')) return Icons.edit_outlined;
    if (subcategory.contains('preguntas')) return Icons.help_outline;
    if (subcategory.contains('rr')) return Icons.book_outlined;
    if (subcategory.contains('pl')) return Icons.directions_bike_outlined;
    return Icons.record_voice_over;
  }

  @override
  Widget build(BuildContext context) {
    final Color circleColor = isLocked ? const Color(0xFFE0E0E0) : AppTheme.greenAccent;
    final Color iconColor = isLocked ? const Color(0xFFBDBDBD) : Colors.white;

    return InkWell(
      onTap: isLocked ? null : () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExerciseScreen(exercise: exercise)));
      },
      borderRadius: BorderRadius.circular(50),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 3))]
                ),
              ),
              CircleAvatar(
                radius: 35,
                backgroundColor: circleColor,
                child: Icon(
                  isLocked ? Icons.lock : _getIconForSubcategory(exercise.subcategory),
                  color: iconColor,
                  size: 35,
                ),
              ),
              Positioned(
                bottom: -8,
                child: Icon(Icons.workspace_premium_rounded, color: isLocked ? Colors.orange[300] : Colors.orange[600], size: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 90,
            child: Text(
              exercise.textContent,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}