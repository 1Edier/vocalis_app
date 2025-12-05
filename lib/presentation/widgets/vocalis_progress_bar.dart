import 'package:flutter/material.dart';
import 'glass_app_bar.dart'; // Para VocalisColors

class VocalisProgressBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final double height;
  final int? markerPosition;
  final String? leftLabel;
  final String? rightLabel;
  final bool showLabels;

  const VocalisProgressBar({
    super.key,
    required this.value,
    this.maxValue = 100,
    this.height = 8,
    this.markerPosition,
    this.leftLabel,
    this.rightLabel,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (value / maxValue).clamp(0.0, 1.0);

    return Column(
      children: [
        if (showLabels && (leftLabel != null || rightLabel != null))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (leftLabel != null)
                  Text(
                    leftLabel!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (rightLabel != null)
                  Text(
                    rightLabel!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
              ],
            ),
          ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: isDark
                  ? VocalisColors.progressBgDark
                  : VocalisColors.progressBgLight,
              color: Theme.of(context).colorScheme.secondary,
              minHeight: height,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            if (markerPosition != null)
              LayoutBuilder(
                builder: (context, constraints) {
                  final markerPercentage = (markerPosition! / maxValue).clamp(0.0, 1.0);
                  return Positioned(
                    left: constraints.maxWidth * markerPercentage,
                    top: -3,
                    bottom: -3,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

class VocalisCategoryProgressBar extends StatelessWidget {
  final String categoryName;
  final int completed;
  final int total;
  final int stars;

  const VocalisCategoryProgressBar({
    super.key,
    required this.categoryName,
    required this.completed,
    required this.total,
    this.stars = 0,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (total > 0) ? completed / total : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDark
          ? VocalisColors.bgScreenCenter
          : const Color(0xFFF8FAFB),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$completed / $total',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: isDark
                  ? VocalisColors.progressBgDark
                  : VocalisColors.progressBgLight,
              color: Theme.of(context).colorScheme.secondary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: stars > 0 
                      ? const Color(0xFFFFB020) 
                      : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$stars estrellas obtenidas',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

