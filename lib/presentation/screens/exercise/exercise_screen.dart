import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:vocalis/data/repositories/progression_repository.dart';
import 'package:vocalis/presentation/bloc/auth/auth_bloc.dart';
import 'package:vocalis/presentation/screens/main_scaffold.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/exercise_detail_model.dart';
import '../../../data/models/process_audio_result.dart';
import '../../bloc/exercise/exercise_bloc.dart';

// Paleta de colores
const Color _primaryColor = Color(0xFF6A1B9A);
const Color _secondaryColor = Color(0xFFF3E5F5);
const Color _accentColor = Color(0xFF7D5AD8);

class ExerciseScreen extends StatefulWidget {
  final String exerciseId;
  const ExerciseScreen({super.key, required this.exerciseId});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final GlobalKey _blocProviderKey = GlobalKey();

  @override
  void dispose() {
    final bloc = _blocProviderKey.currentContext?.read<ExerciseBloc>();
    bloc?.add(StopAudioPlayback());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: _blocProviderKey,
      create: (context) => ExerciseBloc(
        progressionRepository: RepositoryProvider.of<ProgressionRepository>(context),
      )..add(FetchExerciseDetail(widget.exerciseId)),
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
            bottomNavigationBar: _buildBottomBar(context),
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
            isEnabled: state is! RecordingInProgress,
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
            Text('${score.toStringAsFixed(0)} / 100 puntos', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          clipBehavior: Clip.none,
          children: [
            LinearProgressIndicator(
              value: score / 100.0,
              backgroundColor: Colors.grey[300],
              color: _primaryColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Positioned(
                  left: constraints.maxWidth * (requiredScore / 100.0),
                  top: -3, bottom: -3,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2), border: Border.all(color: _primaryColor.withOpacity(0.5))),
                  ),
                );
              },
            ),
          ],
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
    if (state is ProcessingSuccess || state is ProcessingFailure) {
      return Column(
        children: [
          state is ProcessingSuccess
              ? _buildProcessingResultCard(context, state.result)
              : _buildProcessingResultCard(context, null, error: (state as ProcessingFailure).error),
          const SizedBox(height: 16),
          _buildActionButtons(context, state),
        ],
      );
    }
    return const SizedBox(height: 52);
  }

  Widget _buildActionButtons(BuildContext context, ExerciseReadyState state) {
    final bool showContinueButton = (state is ProcessingSuccess) && state.result.isCompleted;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              context.read<ExerciseBloc>().add(StopAudioPlayback());
              context.read<ExerciseBloc>().add(StartRecordingRequested());
            },
            child: const Text('Reintentar'),
            style: OutlinedButton.styleFrom(foregroundColor: _primaryColor, side: const BorderSide(color: _primaryColor), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
        if (showContinueButton) ...[
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                context.read<ExerciseBloc>().add(StopAudioPlayback());
                Navigator.of(context).pop(true);
              },
              child: const Text('Continuar'),
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProcessingResultCard(BuildContext context, ProcessAudioResult? result, {String? error}) {
    final bool isError = error != null;
    final bool isSuccess = !isError && result != null;
    final double score = isSuccess ? result.scores.overall : 0;
    final bool exerciseCompleted = isSuccess && result.isCompleted;
    final int stars = isSuccess ? result.stars : 0;
    final String feedbackMessage = error?.replaceFirst("Exception: ", "") ?? result?.feedback.mainMessage ?? "Error desconocido.";
    final Color cardColor = isError ? Colors.red.withOpacity(0.1) : (exerciseCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1));
    final Color borderColor = isError ? Colors.red : (exerciseCompleted ? Colors.green : Colors.orange);
    final String title = isError ? 'Hubo un Problema' : (exerciseCompleted ? '¡Excelente!' : '¡Sigue Intentando!');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor.withOpacity(0.5))),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: borderColor)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => Icon(index < stars ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber, size: 40)),
          ),
          const SizedBox(height: 8),
          Text('Puntuación: ${score.toStringAsFixed(0)} / 100', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          const SizedBox(height: 16),
          Text(feedbackMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey[800])),
          if (isSuccess) ...[
            if (result.feedback.strengths.isNotEmpty || result.feedback.areasToImprove.isNotEmpty)
              const Divider(height: 32, thickness: 1, indent: 20, endIndent: 20),
            if (result.feedback.strengths.isNotEmpty)
              _FeedbackSectionWidget(title: 'Puntos Fuertes', items: result.feedback.strengths, icon: Icons.check_circle, color: Colors.green),
            if (result.feedback.areasToImprove.isNotEmpty)
              _FeedbackSectionWidget(title: 'Áreas a Mejorar', items: result.feedback.areasToImprove, icon: Icons.lightbulb, color: Colors.orange),
          ]
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BottomNavigationBar(
      // --- CORRECCIÓN: Lista de ítems reducida a 3 ---
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.flag_rounded), label: 'Metas'),
        BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Ajustes'),
      ],
      currentIndex: 1, // El ícono de "Metas" sigue seleccionado
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey[600],
      onTap: (index) {
        if (index == 1) return; // Si se toca "Metas", no hace nada

        final authState = context.read<AuthBloc>().state;
        if (authState is AuthSuccess) {
          // El 'initialIndex' se ajustará al nuevo layout de 3 pestañas
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => MainScaffold(user: authState.user, initialIndex: index)),
                (route) => false,
          );
        }
      },
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 8.0,
      iconSize: 28,
    );
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          context.read<ExerciseBloc>().add(StopAudioPlayback());
          Navigator.of(context).pop(false);
        },
      ),
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
  final bool isEnabled;
  final VoidCallback onPlay;
  const LottieAudioPlayer({super.key, required this.isPlaying, required this.onPlay, this.isEnabled = true});

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
              icon: Opacity(
                opacity: widget.isEnabled ? 1.0 : 0.5,
                child: Container(
                  width: 72, height: 72,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: _accentColor, boxShadow: [BoxShadow(color: _accentColor, blurRadius: 10, spreadRadius: -5)]),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
                ),
              ),
              onPressed: widget.isEnabled ? widget.onPlay : null,
            ),
        ],
      ),
    );
  }
}