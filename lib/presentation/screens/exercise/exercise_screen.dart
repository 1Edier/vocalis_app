import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../../bloc/exercise/exercise_bloc.dart';

class ExerciseScreen extends StatelessWidget {
  final Lesson lesson;
  const ExerciseScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExerciseBloc(
        lessonRepository: RepositoryProvider.of<LessonRepository>(context),
      )..add(FetchExercise(lesson.id)),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: const _ExerciseAppBar(),
        body: BlocBuilder<ExerciseBloc, ExerciseState>(
          builder: (context, state) {
            if (state is ExerciseLoading || state is ExerciseInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ExerciseReadyState) {
              return _buildExerciseContent(context, state);
            }
            return const Center(child: Text('Error al cargar el ejercicio.'));
          },
        ),
        // Creamos un bottom bar personalizado para esta vista
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildExerciseContent(BuildContext context, ExerciseReadyState state) {
    final exercise = state.exercise;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                'Escucha y repite la siguiente palabra',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(exercise.avatarUrl),
                  ),
                  ElevatedButton.icon(
                    onPressed: state is! AudioPlaying ? () {
                      context.read<ExerciseBloc>().add(PlayAudioRequested());
                    } : null,
                    icon: state is AudioPlaying
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,))
                        : const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                    label: Text(exercise.word, style: const TextStyle(fontSize: 24, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.greenAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  )
                ],
              ),
            ],
          ),
          _buildRecorderButton(context, state),
          ElevatedButton(
            onPressed: state is RecordingComplete ? () { /* Navegar al siguiente paso */ } : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFFE0E0E0),
              disabledBackgroundColor: const Color(0xFFE0E0E0),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.grey[500],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecorderButton(BuildContext context, ExerciseReadyState state) {
    String text = 'Toca para grabar';
    IconData icon = Icons.mic_none;
    VoidCallback? onPressed = () => context.read<ExerciseBloc>().add(StartRecordingRequested());

    if (state is RecordingInProgress) {
      text = 'Grabando...';
      icon = Icons.stop;
      onPressed = () => context.read<ExerciseBloc>().add(StopRecordingRequested());
    } else if (state is RecordingComplete) {
      text = '¡Grabación completada!';
      icon = Icons.check_circle;
      onPressed = null; // Deshabilitado después de grabar
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black87, size: 28),
      label: Text(text, style: const TextStyle(fontSize: 20, color: Colors.black87)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.greenAccent,
        disabledBackgroundColor: AppTheme.greenAccent.withOpacity(0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 20),
        minimumSize: const Size(double.infinity, 60),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Metas'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Comunidad'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
          ],
          currentIndex: 1, // La meta está seleccionada
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          iconSize: 28,
        ),
      ),
    );
  }
}

class _ExerciseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ExerciseAppBar();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: false,
      title: Text('Fonema "Rr"', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20)),
      actions: [
        Icon(Icons.workspace_premium_rounded, color: Colors.orange[600], size: 20),
        const SizedBox(width: 4),
        Text('18', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 16)),
        const SizedBox(width: 16),
        const Icon(Icons.diamond_outlined, color: Colors.cyan, size: 20),
        const SizedBox(width: 4),
        Text('213', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 16)),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}