import 'package:flutter/material.dart';

class StarsDisplay extends StatelessWidget {
  final int earnedStars;
  final int totalStars;
  final double size;
  final Color? earnedColor;
  final Color? emptyColor;
  final bool showShadow;
  final MainAxisAlignment alignment;

  const StarsDisplay({
    super.key,
    required this.earnedStars,
    this.totalStars = 3,
    this.size = 40,
    this.earnedColor,
    this.emptyColor,
    this.showShadow = true,
    this.alignment = MainAxisAlignment.center,
  });

  /// Constructor para mostrar estrellas vacías (bloqueadas)
  const StarsDisplay.locked({
    super.key,
    this.totalStars = 3,
    this.size = 22,
    this.emptyColor = const Color(0xB3BDBDBD),
    this.alignment = MainAxisAlignment.center,
  })  : earnedStars = 0,
        earnedColor = null,
        showShadow = false;

  /// Constructor para mostrar estrellas ganadas
  const StarsDisplay.earned({
    super.key,
    required this.earnedStars,
    this.size = 22,
    this.earnedColor = const Color(0xFFFFD700),
    this.alignment = MainAxisAlignment.center,
  })  : totalStars = earnedStars,
        emptyColor = null,
        showShadow = true;

  @override
  Widget build(BuildContext context) {
    if (totalStars <= 0) return const SizedBox.shrink();

    final Color starEarnedColor = earnedColor ?? Colors.amber;
    final Color starEmptyColor = emptyColor ?? Colors.grey.withOpacity(0.4);

    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalStars, (index) {
        final bool isEarned = index < earnedStars;
        return Icon(
          isEarned ? Icons.star_rounded : Icons.star_border_rounded,
          color: isEarned ? starEarnedColor : starEmptyColor,
          size: size,
          shadows: isEarned && showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        );
      }),
    );
  }
}

class AnimatedStarsDisplay extends StatefulWidget {
  final int earnedStars;
  final int totalStars;
  final double size;
  final Duration animationDuration;
  final Duration delayBetweenStars;

  const AnimatedStarsDisplay({
    super.key,
    required this.earnedStars,
    this.totalStars = 3,
    this.size = 40,
    this.animationDuration = const Duration(milliseconds: 300),
    this.delayBetweenStars = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedStarsDisplay> createState() => _AnimatedStarsDisplayState();
}

class _AnimatedStarsDisplayState extends State<AnimatedStarsDisplay>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.totalStars,
      (index) => AnimationController(
        vsync: this,
        duration: widget.animationDuration,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();
  }

  void _startAnimations() async {
    for (int i = 0; i < widget.earnedStars && i < widget.totalStars; i++) {
      await Future.delayed(widget.delayBetweenStars);
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.totalStars, (index) {
        final bool isEarned = index < widget.earnedStars;

        if (!isEarned) {
          return Icon(
            Icons.star_border_rounded,
            color: Colors.grey.withOpacity(0.4),
            size: widget.size,
          );
        }

        return AnimatedBuilder(
          animation: _scaleAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimations[index].value,
              child: Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: widget.size,
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

