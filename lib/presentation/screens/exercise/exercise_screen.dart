import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/audio_validation_result.dart';
import '../../../data/models/exercise_model.dart';
import '../../bloc/exercise/exercise_bloc.dart';

class ExerciseScreen extends StatelessWidget {
  final ExerciseModel exercise;
  const ExerciseScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExerciseBloc()..add(InitializeExercise(exercise)),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: _ExerciseAppBar(phoneme: exercise.category),
        body: _buildExerciseContent(context),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildExerciseContent(BuildContext context) {
    const instructionText = 'Escucha y repite la siguiente palabra';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sección Superior: Instrucciones y botón de play
          Column(
            children: [
              // --- SECCIÓN DE INSTRUCCIONES ACTUALIZADA ---
              BlocBuilder<ExerciseBloc, ExerciseState>(
                builder: (context, state) {
                  final bool isSpeaking = (state is ExerciseReadyState) ? state.isInstructionSpeaking : false;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          instructionText,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.volume_up_rounded,
                          color: isSpeaking ? AppTheme.primaryColor : Colors.grey,
                        ),
                        // Deshabilitamos el botón mientras está hablando
                        onPressed: isSpeaking ? null : () {
                          context.read<ExerciseBloc>().add(const PlayInstructionRequested(instructionText));
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  const SizedBox(width: 16),
                  Flexible(
                    child: BlocBuilder<ExerciseBloc, ExerciseState>(
                      builder: (context, state) {
                        if (state is AudioPlaying) {
                          return _buildAudioPlayingIndicator(context, state.exercise);
                        }
                        return AnimatedPlayButton(
                          text: exercise.textContent,
                          onPressed: () {
                            context.read<ExerciseBloc>().add(PlayAudioRequested());
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
          // Sección Media: Botón de grabar y feedback
          Column(
            children: [
              _buildRecorderButton(context),
              const SizedBox(height: 20),
              _buildFeedbackSection(context),
            ],
          ),
          // Sección Inferior: Botón de continuar
          BlocBuilder<ExerciseBloc, ExerciseState>(
            builder: (context, state) {
              final bool isEnabled = state is ValidationSuccess && state.result.isValid;
              return ElevatedButton(
                onPressed: isEnabled ? () {} : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: isEnabled ? AppTheme.primaryColor : const Color(0xFFE0E0E0),
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.grey[500],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Continuar'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayingIndicator(BuildContext context, ExerciseModel exercise) {
    return Column(
      children: [
        const EnhancedPulseAnimation(color: AppTheme.greenAccent, size: 90),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.greenAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.greenAccent.withOpacity(0.3), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hearing, color: AppTheme.greenAccent, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  exercise.textContent,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.grey[800], letterSpacing: 1.2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('Reproduciendo audio...', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildRecorderButton(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        String text = 'Toca para grabar';
        IconData icon = Icons.mic_none;
        VoidCallback? onPressed = () => context.read<ExerciseBloc>().add(StartRecordingRequested());

        if (state is RecordingInProgress) {
          text = 'Grabando...';
          icon = Icons.stop;
          onPressed = () => context.read<ExerciseBloc>().add(StopRecordingRequested());
        } else if (state is ValidationSuccess || state is ValidationFailure) {
          text = '¡Vuelve a grabar!';
          icon = Icons.refresh;
          onPressed = () => context.read<ExerciseBloc>().add(StartRecordingRequested());
        } else if (state is AudioPlaying || state is ValidatingAudio) {
          onPressed = null;
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
      },
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is ValidatingAudio) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(width: 16), Text("Analizando tu audio...")]),
          );
        }
        if (state is ValidationSuccess) {
          return _buildValidationResultCard(context, state.result);
        }
        if (state is ValidationFailure) {
          return _buildValidationResultCard(context, null, error: state.error);
        }
        if (state is RecordingComplete) {
          return _buildUserAudioPlayer(context, state);
        }
        return const SizedBox(height: 74);
      },
    );
  }

  Widget _buildValidationResultCard(BuildContext context, AudioValidationResult? result, {String? error}) {
    final bool isError = error != null;
    final bool isValid = !isError && (result?.isValid ?? false);
    final Color cardColor = isError ? Colors.orange.withOpacity(0.1) : (isValid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1));
    final Color borderColor = isError ? Colors.orange.withOpacity(0.5) : (isValid ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5));
    final Color textColor = isError ? Colors.orange[800]! : (isValid ? Colors.green[800]! : Colors.red[800]!);
    final IconData iconData = isError ? Icons.warning_amber_rounded : (isValid ? Icons.check_circle : Icons.cancel);
    final String title = isError ? "Error de Validación" : (isValid ? '¡Buen trabajo!' : 'Inténtalo de nuevo');
    final String recommendation = error ?? result?.recommendation ?? "Hubo un problema al procesar la respuesta.";

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(iconData, color: textColor, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                const SizedBox(height: 4),
                Text(recommendation, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUserAudioPlayer(BuildContext context, ExerciseReadyState state) {
    final isPlaying = state.isUserAudioPlaying;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Tu grabación", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 36, color: AppTheme.primaryColor),
            onPressed: () {
              if (isPlaying) {
                context.read<ExerciseBloc>().add(StopUserAudioRequested());
              } else {
                context.read<ExerciseBloc>().add(PlayUserAudioRequested());
              }
            },
          ),
        ],
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
          currentIndex: 1,
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

// --- WIDGETS DE ANIMACIÓN Y APPBAR ---

class AnimatedPlayButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  const AnimatedPlayButton({super.key, required this.text, required this.onPressed});
  @override
  State<AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<AnimatedPlayButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.greenAccent, AppTheme.greenAccent.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppTheme.greenAccent.withOpacity(0.4), blurRadius: 12, spreadRadius: 2, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 12),
              // --- AQUÍ ESTÁ LA CORRECCIÓN CLAVE ---
              // Se han eliminado las propiedades 'overflow', 'maxLines' y 'softWrap'
              // para permitir que el texto se ajuste en múltiples líneas si es necesario.
              Flexible(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EnhancedPulseAnimation extends StatefulWidget {
  final Color color;
  final double size;
  const EnhancedPulseAnimation({super.key, this.color = Colors.green, this.size = 60});
  @override
  State<EnhancedPulseAnimation> createState() => _EnhancedPulseAnimationState();
}

class _EnhancedPulseAnimationState extends State<EnhancedPulseAnimation> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
    _rotationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut));
  }
  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotationController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildPulseWave(scale: 1.0 + (_pulseAnimation.value * 1.2), opacity: (1.0 - _pulseAnimation.value) * 0.6, width: 4),
            if (_pulseAnimation.value > 0.2)
              _buildPulseWave(scale: 1.0 + ((_pulseAnimation.value - 0.2) * 1.0), opacity: (1.0 - (_pulseAnimation.value - 0.2) * 1.25) * 0.7, width: 3),
            if (_pulseAnimation.value > 0.4)
              _buildPulseWave(scale: 1.0 + ((_pulseAnimation.value - 0.4) * 0.8), opacity: (1.0 - (_pulseAnimation.value - 0.4) * 1.66) * 0.8, width: 2),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: RadialGradient(colors: [widget.color.withOpacity(0.9), widget.color]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: widget.color.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)],
              ),
            ),
            Transform.rotate(angle: _rotationAnimation.value, child: Icon(Icons.volume_up_rounded, color: Colors.white, size: widget.size * 0.5)),
            ..._buildFloatingParticles(),
          ],
        );
      },
    );
  }
  Widget _buildPulseWave({required double scale, required double opacity, required double width}) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: widget.color.withOpacity(opacity.clamp(0.0, 1.0)), width: width),
        ),
      ),
    );
  }
  List<Widget> _buildFloatingParticles() {
    return List.generate(3, (index) {
      final angle = (index * 120.0) * (pi / 180.0);
      final distance = widget.size * 0.7 * _pulseAnimation.value;
      final x = distance * cos(angle);
      final y = distance * sin(angle);
      return Transform.translate(
        offset: Offset(x, y),
        child: Opacity(
          opacity: (1.0 - _pulseAnimation.value).clamp(0.0, 1.0),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: widget.color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)],
            ),
          ),
        ),
      );
    });
  }
}

class _ExerciseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String phoneme;
  const _ExerciseAppBar({required this.phoneme});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: false,
      title: Text('Fonema "$phoneme"', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20)),
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