import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../../bloc/lesson_detail/lesson_detail_bloc.dart';
import '../exercise/exercise_screen.dart';

class LessonDetailScreen extends StatelessWidget {
  final LessonCategory category;
  const LessonDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LessonDetailBloc(
        lessonRepository: RepositoryProvider.of<LessonRepository>(context),
      )..add(FetchLessonsForCategory(category.id)),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(category.title),
              const SizedBox(width: 8),
              Icon(Icons.workspace_premium_rounded, color: Colors.orange[600], size: 20),
              Text(' 3', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
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
              final lessons = state.lessons;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    _buildMainLessonCard(),
                    const SizedBox(height: 32),
                    _buildLessonRow([lessons[0], lessons[1], lessons[2]]),
                    const SizedBox(height: 24),
                    _buildLessonRow([lessons[3]]),
                    const SizedBox(height: 24),
                    _buildLessonRow([lessons[4], lessons[5]]),
                  ],
                ),
              );
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

  Widget _buildMainLessonCard() {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Puedes usar un asset local o una URL de red
          Image.network('https://cdn-icons-png.flaticon.com/512/3209/3209861.png', height: 60),
          const SizedBox(height: 12),
          const Text('Lvl 1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 3 / 40,
            backgroundColor: Colors.grey[300],
            color: Colors.orange[600],
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 4),
          Text('3/40', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLessonRow(List<Lesson> lessons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: lessons.map((lesson) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _LessonCircle(lesson: lesson),
      )).toList(),
    );
  }
}

class _LessonCircle extends StatelessWidget {
  final Lesson lesson;
  const _LessonCircle({required this.lesson});

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'pencil': return Icons.edit_outlined;
      case 'book': return Icons.book_outlined;
      case 'bike': return Icons.directions_bike_outlined;
      default: return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color circleColor = lesson.isLocked ? const Color(0xFFE0E0E0) : AppTheme.greenAccent;
    final Color iconColor = lesson.isLocked ? const Color(0xFFBDBDBD) : Colors.white;

    // Se envuelve el widget en un InkWell para el efecto visual al tocar
    // y un GestureDetector para la lógica de navegación.
    return InkWell(
      onTap: lesson.isLocked ? null : () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExerciseScreen(lesson: lesson),
          ),
        );
      },
      borderRadius: BorderRadius.circular(50), // Hace que el "splash" sea redondo
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
                  lesson.isLocked ? Icons.lock : _getIconFromString(lesson.iconName),
                  color: iconColor,
                  size: 35,
                ),
              ),
              if (lesson.badgeCount > 0)
                Positioned(
                  bottom: -5,
                  right: -5,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.orange[600],
                    child: Text(
                      lesson.badgeCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (lesson.isLocked)
                Positioned(
                  bottom: -8,
                  child: Icon(Icons.workspace_premium_rounded, color: Colors.orange[300], size: 24),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (!lesson.isLocked)
            Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}