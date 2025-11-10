import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/models/lesson_model.dart'; // Aún lo necesitamos para el título
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

  @override
  Widget build(BuildContext context) {
    // Mapeamos el título de la UI a la categoría de la API
    // ej: "Fonemas" -> "fonema"
    final apiCategory = category.title.toLowerCase().replaceAll('ó', 'o').replaceAll('á', 'a');

    return BlocProvider(
      // Proveemos una instancia del ExerciseRepository aquí
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
              // Construimos el layout de "camino" vertical
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

  // Widget principal que construye el layout de la maqueta
  Widget _buildPathLayout(BuildContext context, List<ExerciseModel> exercises) {
    // Simulación de progreso y bloqueo para replicar el diseño
    int completedExercises = 3;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          _buildMainLessonCard(context, level, completedExercises, exercises.length),
          const SizedBox(height: 32),
          // Construimos las filas de círculos dinámicamente
          _buildLessonRow(context, exercises, 0, 1, completedExercises), // Fila con 1 ejercicio
          const SizedBox(height: 24),
          _buildLessonRow(context, exercises, 1, 2, completedExercises), // Fila con 2 ejercicios
          const SizedBox(height: 24),
          _buildLessonRow(context, exercises, 3, 1, completedExercises), // Fila con 1 ejercicio
          const SizedBox(height: 24),
          _buildLessonRow(context, exercises, 4, 2, completedExercises), // Fila con 2 ejercicios
        ],
      ),
    );
  }

  // Helper para construir una fila de ejercicios
  Widget _buildLessonRow(BuildContext context, List<ExerciseModel> exercises, int startIndex, int count, int completedCount) {
    // Asegurarse de no intentar acceder a índices fuera de la lista
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
            // Desbloqueado si su índice es menor al número de completados
            isLocked: exerciseIndex >= completedCount,
          ),
        );
      }),
    );
  }

  // La tarjeta principal superior
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
          Image.network('https://cdn-icons-png.flaticon.com/512/3209/3209861.png', height: 60),
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

  // Mapea la subcategoría de la API a un icono visual
  IconData _getIconForSubcategory(String subcategory) {
    // Puedes expandir esto con más casos
    if (subcategory.contains('afirmaciones')) return Icons.edit_outlined;
    if (subcategory.contains('preguntas')) return Icons.help_outline;
    if (subcategory.contains('rr')) return Icons.book_outlined;
    if (subcategory.contains('pl')) return Icons.directions_bike_outlined;
    return Icons.record_voice_over; // Icono por defecto
  }

  @override
  Widget build(BuildContext context) {
    final Color circleColor = isLocked ? const Color(0xFFE0E0E0) : AppTheme.greenAccent;
    final Color iconColor = isLocked ? const Color(0xFFBDBDBD) : Colors.white;

    return InkWell(
      onTap: isLocked ? null : () {
        // La navegación a ExerciseScreen ahora debe ser actualizada para pasar
        // el objeto ExerciseModel completo
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
          // El texto ahora es el 'text_content' del ejercicio
          SizedBox(
            width: 90, // Ancho fijo para que el texto se ajuste
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