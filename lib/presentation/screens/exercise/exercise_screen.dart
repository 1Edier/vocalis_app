import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:vocalis/data/repositories/progression_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/exercise_detail_model.dart';
import '../../../data/models/process_audio_result.dart';
import '../../bloc/exercise/exercise_bloc.dart';

// Paleta de colores para el nuevo diseño
const Color _primaryColor = Color(0xFF6A1B9A);
const Color _secondaryColor = Color(0xFFF3E5F5);
const Color _accentColor = Color(0xFF7D5AD8);

class ExerciseScreen extends StatelessWidget {
  final String exerciseId;
  const ExerciseScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExerciseBloc(
        progressionRepository: RepositoryProvider.of<ProgressionRepository>(context),
      )..add(FetchExerciseDetail(exerciseId)),
      child: BlocBuilder<ExerciseBloc, ExerciseState>(
        builder: (context, state) {
          if (state is ExerciseLoading || state is ExerciseInitial) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: _primaryColor, elevation: 0,
                title: const Text('Cargando Ejercicio...', style: TextStyle(color: Colors.white, fontSize: 18)),
                leading: const BackButton(color: Colors.white),
              ),
              body: Center(child: Lottie.asset('assets/lottie/cat_loader.json', width: 200, height: 200, repeat: true)),
            );
          }
          if (state is ExerciseLoadFailure) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(backgroundColor: _primaryColor, leading: const BackButton(color: Colors.white)),
              body: const Center(child: Text("Error al cargar el ejercicio.")),
            );
          }

          final exercise = (state as ExerciseReadyState).exercise;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _ExerciseAppBar(level: exercise.orderIndex, title: exercise.title),
            body: _buildExerciseContent(context, state as ExerciseReadyState),
          );
        },
      ),
    );
  }

  Widget _buildExerciseContent(BuildContext context, ExerciseReadyState state) {
    final exercise = state.exercise;
    final score = (state is ProcessingSuccess) ? state.result.scores.overall : exercise.bestScore;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('PALABRA', style: TextStyle(color: Colors.grey, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(exercise.textContent, textAlign: TextAlign.center, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: _primaryColor)),
          const SizedBox(height: 24),
          LottieAudioPlayer(
            isPlaying: state is AudioPlaying,
            onPlay: () => context.read<ExerciseBloc>().add(PlayAudioRequested()),
          ),
          const SizedBox(height: 32),
          if (exercise.tips.isNotEmpty) _buildTipsCard(context, exercise.tips),
          const SizedBox(height: 32),
          _buildProgressBar(context, score, exercise.unlockScoreRequired),
          const SizedBox(height: 24),
          _buildRecorderButton(context, state),
          const SizedBox(height: 16),
          _buildFeedbackOrActions(context, state),
        ],
      ),
    );
  }

  Widget _buildTipsCard(BuildContext context, List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _secondaryColor, borderRadius: BorderRadius.circular(16), border: Border(left: BorderSide(color: _primaryColor.withOpacity(0.5), width: 5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 24), SizedBox(width: 8), Text('Consejos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor))]),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: _primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(child: Text(tip, style: const TextStyle(fontSize: 16, color: Colors.black87))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double score, int requiredScore) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Progreso para desbloquear', style: TextStyle(color: Colors.grey)),
            Text('${score.toStringAsFixed(0)} / $requiredScore puntos', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: score / requiredScore.toDouble().clamp(1, 100),
          backgroundColor: Colors.grey[300],
          color: _primaryColor,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildRecorderButton(BuildContext context, ExerciseReadyState state) {
    String text = 'Grabar mi pronunciación';
    IconData icon = Icons.mic_none_rounded;
    VoidCallback? onPressed = () => context.read<ExerciseBloc>().add(StartRecordingRequested());

    if (state is RecordingInProgress) {
      text = 'Grabando...';
      icon = Icons.stop_rounded;
      onPressed = () => context.read<ExerciseBloc>().add(StopRecordingRequested());
    } else if (state is AudioPlaying || state is ProcessingAudio || state is ProcessingSuccess || state is ProcessingFailure) {
      onPressed = null;
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 24),
      label: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, disabledBackgroundColor: _primaryColor.withOpacity(0.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16), minimumSize: const Size(double.infinity, 50)),
    );
  }

  Widget _buildFeedbackOrActions(BuildContext context, ExerciseReadyState state) {
    if (state is ProcessingAudio) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Center(child: CircularProgressIndicator()));
    }
    if (state is ProcessingSuccess) {
      return Column(
        children: [
          _buildProcessingResultCard(context, state.result),
          const SizedBox(height: 16),
          _buildActionButtons(context, state),
        ],
      );
    }
    if (state is ProcessingFailure) {
      return Column(
        children: [
          _buildProcessingResultCard(context, null, error: state.error),
          const SizedBox(height: 16),
          _buildActionButtons(context, state),
        ],
      );
    }
    return const SizedBox(height: 52);
  }

  Widget _buildActionButtons(BuildContext context, ExerciseReadyState state) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.read<ExerciseBloc>().add(StartRecordingRequested()),
            child: const Text('Reintentar'),
            style: OutlinedButton.styleFrom(foregroundColor: _primaryColor, side: const BorderSide(color: _primaryColor), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop((state is ProcessingSuccess) && state.result.isCompleted),
            child: const Text('Continuar'),
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingResultCard(BuildContext context, ProcessAudioResult? result, {String? error}) {
    // Caso de Error
    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.withOpacity(0.5))),
        child: Column(children: [
          const Text('Hubo un Problema', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
          const SizedBox(height: 16),
          Text(error.replaceFirst("Exception: ", ""), textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey[800])),
        ]),
      );
    }

    // Caso de Éxito
    if (result != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[300]!), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          children: [
            Text(result.feedback.mainMessage, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20, color: AppTheme.primaryColor), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text('${result.scores.overall.toStringAsFixed(0)}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text('Puntuación General', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => Icon(index < result.stars ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber, size: 40)),
            ),
            if (result.feedback.strengths.isNotEmpty || result.feedback.areasToImprove.isNotEmpty)
              const Divider(height: 32, thickness: 1, indent: 20, endIndent: 20),
            if (result.feedback.strengths.isNotEmpty)
              _FeedbackSectionWidget(title: 'Puntos Fuertes', items: result.feedback.strengths, icon: Icons.check_circle, color: Colors.green),
            if (result.feedback.areasToImprove.isNotEmpty)
              _FeedbackSectionWidget(title: 'Áreas a Mejorar', items: result.feedback.areasToImprove, icon: Icons.lightbulb, color: Colors.orange),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _FeedbackSectionWidget extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  const _FeedbackSectionWidget({required this.title, required this.items, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: TextStyle(color: Colors.grey[800]))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _ExerciseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int level;
  final String title;
  const _ExerciseAppBar({required this.level, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _primaryColor,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      centerTitle: true,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop(false)),
      title: Column(
        children: [
          Text('NIVEL $level', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}

class LottieAudioPlayer extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onPlay;
  const LottieAudioPlayer({super.key, required this.isPlaying, required this.onPlay});
  @override
  State<LottieAudioPlayer> createState() => _LottieAudioPlayerState();
}

class _LottieAudioPlayerState extends State<LottieAudioPlayer> with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _lottieController.reset();
        _lottieController.forward();
      }
    });
  }
  @override
  void didUpdateWidget(covariant LottieAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _lottieController.repeat();
      } else {
        _lottieController.stop();
        _lottieController.reset();
      }
    }
  }
  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/audio_wave.json',
            controller: _lottieController,
            width: 120,
            height: 120,
            onLoaded: (composition) {
              _lottieController.duration = composition.duration;
            },
          ),
          if (!widget.isPlaying)
            IconButton(
              iconSize: 72,
              icon: Container(
                width: 72, height: 72,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: _accentColor, boxShadow: [BoxShadow(color: _accentColor, blurRadius: 10, spreadRadius: -5)]),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
              ),
              onPressed: widget.onPlay,
            ),
        ],
      ),
    );
  }
}