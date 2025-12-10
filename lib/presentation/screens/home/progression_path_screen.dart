// lib/presentation/screens/progression_path_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vocalis/core/routing/app_routes.dart';
import 'package:vocalis/presentation/bloc/progression/progression_bloc.dart';
import '../../../data/models/progression_map_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/widgets.dart';

// Constantes de diseño
const double _nodeSize = 85.0;
const double _verticalSpacing = 160.0;
const double _topPaddingForStars = 20.0;

// Paleta de colores
const Color _unlockedPlanetColor = Color(0xFF4DB6AC);
const Color _completedPlanetColor = Color(0xFF4DB6AC);
const Color _lockedPlanetColor = Color(0xFF757575);
const Color _lineColor = Color(0x99E0E0E0);

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

  const _PathSegment({required this.exercise, required this.isNodeOnLeft, required this.hasNextNode});

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

    Color planetColor;
    Widget nodeContent;

    if (isLocked) {
      planetColor = _lockedPlanetColor;
      nodeContent = const Icon(Icons.lock, color: Colors.white, size: 40);
    } else {
      planetColor = isAvailable ? _unlockedPlanetColor : _completedPlanetColor;
      nodeContent = Text(
        '${exercise.orderIndex}',
        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: _topPaddingForStars),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isAvailable) PulsingRing(color: planetColor),
              InkWell(
                onTap: isLocked ? null : () async {
                  // Hacemos push a la pantalla de ejercicio y esperamos un resultado booleano
                  final result = await context.push<bool>(
                      AppRoutes.exerciseDetail(exercise.exerciseId)
                  );
                  // Si el ejercicio fue completado (resultado es true), recargamos el mapa
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Center(child: nodeContent),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: isLocked
              ? const StarsDisplay.locked()
              : (exercise.stars > 0
              ? StarsDisplay.earned(earnedStars: exercise.stars)
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

    final double currentY = _topPaddingForStars + (_nodeSize / 2);

    final Offset startPoint = Offset(isStartNodeOnLeft ? leftX : rightX, currentY);
    final Offset endPoint = Offset(isStartNodeOnLeft ? rightX : leftX, currentY - _verticalSpacing);

    final path = Path()..moveTo(startPoint.dx, startPoint.dy)..lineTo(endPoint.dx, endPoint.dy);

    const double dashWidth = 4;
    const double dashSpace = 4;
    double distance = 0;

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}