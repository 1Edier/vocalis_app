import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'glass_app_bar.dart'; // Para usar VocalisColors

/// Bottom Navigation Bar con efecto glassmorphism.
/// Se adapta automáticamente al tema claro/oscuro.
class GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final bool showLabels;
  final double iconSize;
  final double blurSigma;

  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.showLabels = false,
    this.iconSize = 28,
    this.blurSigma = 10,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? VocalisColors.bgScreenEdge.withOpacity(0.5)
            : Colors.white.withOpacity(0.7),
        border: Border(
          top: BorderSide(
            color: isDark
                ? VocalisColors.neonTurquoise.withOpacity(0.1)
                : Colors.grey.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: BottomNavigationBar(
            items: items,
            currentIndex: currentIndex,
            selectedItemColor: Theme.of(context).colorScheme.secondary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
            onTap: onTap,
            showSelectedLabels: showLabels,
            showUnselectedLabels: showLabels,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconSize: iconSize,
          ),
        ),
      ),
    );
  }
}

/// Items predefinidos para la navegación principal de Vocalis.
class VocalisNavItems {
  static const List<BottomNavigationBarItem> mainItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.flag_rounded),
      label: 'Metas',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people_alt_rounded),
      label: 'Perfil',
    ),
  ];
}

