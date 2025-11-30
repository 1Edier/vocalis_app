import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vocalis/data/models/exercise_model.dart';
import 'package:vocalis/presentation/bloc/progression/progression_bloc.dart';
import 'package:vocalis/presentation/screens/exercise/exercise_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/progression_map_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Constantes de diseño
const double _nodeSize = 85.0;
const double _verticalSpacing = 160.0;
const double _topPaddingForStars = 20.0;

// Paleta de colores
const Color _unlockedPlanetColor = Color(0xFF4DB6AC);
const Color _completedPlanetColor = Color(0xFF4DB6AC); // Restauramos el color para 'completed'
const Color _lockedPlanetColor = Color(0xFF757575);
const Color _lineColor = Color(0x99E0E0E0);
const Color _starColor = Color(0xFFFFD700);
const Color _emptyStarColor = Color(0xB3BDBDBD);

class ProgressionPathScreen extends StatelessWidget {
  final CategoryProgress categoryProgress;
  const ProgressionPathScreen({super.key, required this.categoryProgress});

  @override
  Widget build(BuildContext context) {
    final exercises = categoryProgress.exercises;
    final double totalHeight = exercises.length * _verticalSpacing;
    final ScrollController scrollController = ScrollController(initialScrollOffset: totalHeight);

    return SingleChildScrollView(
      controller: scrollController,
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          children: List.generate(exercises.length, (index) {
            final exercise = exercises[index];
            final bool isNodeOnLeft = index.isEven;
            final double topPosition = (exercises.length - 1 - index) * _verticalSpacing;

            return Positioned(
              top: topPosition,
              left: 0,
              right: 0,
              height: _verticalSpacing,
              child: _PathSegment(
                exercise: exercise,
                isNodeOnLeft: isNodeOnLeft,
                hasNextNode: index < exercises.length - 1,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _PathSegment extends StatelessWidget {
  final ExerciseProgress exercise;
  final bool isNodeOnLeft;
  final bool hasNextNode;

  const _PathSegment({
    required this.exercise,
    required this.isNodeOnLeft,
    required this.hasNextNode,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (hasNextNode)
          CustomPaint(
            painter: DashedLinePainter(
              isStartNodeOnLeft: isNodeOnLeft,
              isUnlocked: exercise.status != 'locked',
            ),
            size: Size.infinite,
          ),

        Align(
          alignment: isNodeOnLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
            child: _PathNode(exercise: exercise),
          ),
        ),
      ],
    );
  }
}

class _PathNode extends StatelessWidget {
  final ExerciseProgress exercise;
  const _PathNode({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final bool isLocked = exercise.status == 'locked';
    final bool isAvailable = exercise.status == 'available';
    final bool isCompleted = exercise.status == 'completed';

    Color planetColor;

    if (isLocked) {
      planetColor = _lockedPlanetColor;
    } else if (isCompleted) {
      planetColor = _completedPlanetColor;
    } else {
      planetColor = _unlockedPlanetColor;
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // La columna contiene el planeta y la etiqueta, con un padding superior
        // para dejar espacio a las estrellas.
        Padding(
          padding: const EdgeInsets.only(top: _topPaddingForStars),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isAvailable) PulsingRing(color: planetColor),

                  InkWell(
                    onTap: isLocked ? null : () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ExerciseScreen(exerciseId: exercise.exerciseId),
                        ),
                      );
                      if (result == true && context.mounted) {
                        context.read<ProgressionBloc>().add(FetchProgressionMap());
                      }
                    },
                    child: Container(
                      width: _nodeSize,
                      height: _nodeSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [_lighten(planetColor, 0.15), planetColor, _darken(planetColor, 0.1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${exercise.orderIndex}',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // --- ETIQUETA DE TÍTULO REINCORPORADA ---
              Container(
                width: _nodeSize + 40,
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: planetColor.withOpacity(isLocked ? 0.7 : 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      exercise.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),

        // Estrellas en la parte superior
        Positioned(
          top: 0,
          child: isLocked
              ? _StarsDisplay(starCount: 3, iconSize: 22, color: _emptyStarColor, earned: false)
              : (exercise.stars > 0
              ? _StarsDisplay(starCount: exercise.stars, iconSize: 22, color: _starColor, earned: true)
              : const SizedBox.shrink()),
        ),
      ],
    );
  }

  Color _lighten(Color color, [double amount = .1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darken(Color color, [double amount = .1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

class _StarsDisplay extends StatelessWidget {
  final int starCount;
  final double iconSize;
  final Color color;
  final bool earned;

  const _StarsDisplay({required this.starCount, this.iconSize = 24.0, required this.color, this.earned = true});

  @override
  Widget build(BuildContext context) {
    if (starCount <= 0) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        return Icon(
          earned ? Icons.star_rounded : Icons.star_border_rounded,
          color: color,
          size: iconSize,
          shadows: [
            if (earned)
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 1))
          ],
        );
      }),
    );
  }
}

class PulsingRing extends StatefulWidget {
  final Color color;
  const PulsingRing({super.key, required this.color});

  @override
  State<PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<PulsingRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: _nodeSize,
            height: _nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: widget.color.withOpacity(_opacityAnimation.value), width: 3),
            ),
          ),
        );
      },
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final bool isStartNodeOnLeft;
  final bool isUnlocked;

  DashedLinePainter({required this.isStartNodeOnLeft, required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _lineColor.withOpacity(isUnlocked ? 0.7 : 0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final horizontalMargin = size.width * 0.1;
    final double leftX = horizontalMargin + (_nodeSize / 2);
    final double rightX = size.width - horizontalMargin - (_nodeSize / 2);

    // --- CORRECCIÓN FINAL DE COORDENADAS ---
    // El centro vertical del nodo actual (el de abajo), teniendo en cuenta el padding.
    final double currentY = _topPaddingForStars + (_nodeSize / 2);

    // Coordenadas del punto de inicio
    final Offset startPoint = Offset(isStartNodeOnLeft ? leftX : rightX, currentY);

    // Coordenadas del punto final (el nodo de arriba)
    final Offset endPoint = Offset(isStartNodeOnLeft ? rightX : leftX, currentY - _verticalSpacing);

    final path = Path()
      ..moveTo(startPoint.dx, startPoint.dy)
      ..lineTo(endPoint.dx, endPoint.dy);

    const double dashWidth = 4;
    const double dashSpace = 4;
    double distance = 0;

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}