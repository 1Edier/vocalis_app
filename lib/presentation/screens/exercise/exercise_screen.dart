// lib/presentation/screens/exercise/exercise_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:vocalis/core/routing/app_routes.dart';
import 'package:vocalis/data/repositories/progression_repository.dart';
import 'package:vocalis/presentation/bloc/auth/auth_bloc.dart';
import '../../../data/models/process_audio_result.dart';
import '../../bloc/exercise/exercise_bloc.dart';
import '../../widgets/widgets.dart';

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
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                title: Text(
                  'Cargando Ejercicio...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                  ),
                ),
                leading: BackButton(color: Theme.of(context).colorScheme.onPrimary),
              ),
              body: Center(
                child: Lottie.asset(
                  'assets/lottie/cat_loader.json',
                  width: 200,
                  height: 200,
                  repeat: true,
                ),
              ),
            );
          }
          if (state is ExerciseLoadFailure) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                leading: BackButton(color: Theme.of(context).colorScheme.onPrimary),
              ),
              body: const Center(child: Text("Error al cargar el ejercicio.")),
            );
          }

          final exercise = (state as ExerciseReadyState).exercise;
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: GlassAppBarWithSubtitle(
              subtitle: 'NIVEL ${exercise.orderIndex}',
              title: exercise.title,
              onBackPressed: () {
                context.read<ExerciseBloc>().add(StopAudioPlayback());
                // Hacemos pop con 'false' para indicar que el ejercicio NO fue completado
                context.pop(false);
              },
            ),
            body: _buildExerciseContent(context, state),
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
          Text(
            'PALABRA',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            exercise.textContent,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? VocalisColors.bgScreenCenter
            : Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            width: 5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFFB020), size: 24),
              const SizedBox(width: 8),
              Text(
                'Consejos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double score, int requiredScore) {
    return VocalisProgressBar(
      value: score,
      markerPosition: requiredScore,
      leftLabel: 'Progreso para desbloquear',
      rightLabel: '${score.toStringAsFixed(0)} / 100 puntos',
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

    return VocalisPrimaryButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
    );
  }

  Widget _buildFeedbackOrActions(BuildContext context, ExerciseReadyState state) {
    if (state is ProcessingAudio) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator()),
      );
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
          child: VocalisOutlinedButton(
            text: 'Reintentar',
            onPressed: () {
              context.read<ExerciseBloc>().add(StopAudioPlayback());
              context.read<ExerciseBloc>().add(StartRecordingRequested());
            },
          ),
        ),
        if (showContinueButton) ...[
          const SizedBox(width: 16),
          Expanded(
            child: VocalisPrimaryButton(
              text: 'Continuar',
              onPressed: () {
                context.read<ExerciseBloc>().add(StopAudioPlayback());
                // Hacemos pop con 'true' para indicar que el ejercicio SÍ fue completado
                context.pop(true);
              },
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
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: borderColor)),
          const SizedBox(height: 16),
          StarsDisplay(earnedStars: stars, totalStars: 3, size: 40),
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
    return GlassBottomNavBar(
      currentIndex: 1, // El botón de atajo está "seleccionado" en esta pantalla
      items: VocalisNavItems.mainItems,
      onTap: (index) {
        if (index == 1) return; // Ya estamos en un ejercicio
        // Usamos context.go para reemplazar la pila de navegación y volver a la shell
        if (index == 0) {
          context.go(AppRoutes.homeMap);
        } else if (index == 2) {
          context.go(AppRoutes.homeProfile);
        }
      },
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
            Builder(
              builder: (context) {
                final primaryColor = Theme.of(context).colorScheme.primary;
                return IconButton(
                  iconSize: 72,
                  icon: Opacity(
                    opacity: widget.isEnabled ? 1.0 : 0.5,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF0a0a0f)
                            : Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  onPressed: widget.isEnabled ? widget.onPlay : null,
                );
              },
            ),
        ],
      ),
    );
  }
}