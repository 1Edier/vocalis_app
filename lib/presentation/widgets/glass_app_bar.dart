import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Colores consistentes para el tema oscuro de la app.
class VocalisColors {
  static const Color bgScreenEdge = Color(0xFF0b1016);
  static const Color bgScreenCenter = Color(0xFF1a2332);
  static const Color neonTurquoise = Color(0xFF2ce0bd);
  static const Color progressBgDark = Color(0xFF2B3A4A);
  static const Color progressBgLight = Color(0xFFE0E7ED);
}

/// AppBar con efecto glassmorphism (blur + transparencia).
/// Se adapta automáticamente al tema claro/oscuro.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double height;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final Color? backgroundColor;
  final double blurSigma;

  const GlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.height = kToolbarHeight,
    this.onBackPressed,
    this.showBackButton = true,
    this.backgroundColor,
    this.blurSigma = 10,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: AppBar(
          toolbarHeight: height,
          backgroundColor: backgroundColor ??
              (isDark
                  ? VocalisColors.bgScreenEdge.withOpacity(0.7)
                  : Colors.white.withOpacity(0.8)),
          elevation: 0,
          centerTitle: centerTitle,
          leading: leading ??
              (showBackButton
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark
                            ? VocalisColors.neonTurquoise
                            : Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                    )
                  : null),
          title: titleWidget ??
              (title != null
                  ? Text(
                      title!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null),
          actions: actions,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? VocalisColors.neonTurquoise.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.15),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

/// AppBar con título de dos líneas (nivel + título).
/// Útil para pantallas de ejercicios.
class GlassAppBarWithSubtitle extends StatelessWidget implements PreferredSizeWidget {
  final String subtitle;
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const GlassAppBarWithSubtitle({
    super.key,
    required this.subtitle,
    required this.title,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassAppBar(
      height: kToolbarHeight + 10,
      onBackPressed: onBackPressed,
      actions: actions,
      titleWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              color: isDark
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isDark
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: isDark
          ? VocalisColors.bgScreenEdge.withOpacity(0.7)
          : Theme.of(context).colorScheme.primary.withOpacity(0.95),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}

/// Header con glassmorphism para usar dentro de un Column/ListView.
/// No es un AppBar, es solo un contenedor con el efecto glass.
class GlassHeader extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsets? padding;

  const GlassHeader({
    super.key,
    required this.child,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: isDark
                ? VocalisColors.bgScreenEdge.withOpacity(0.7)
                : Colors.white.withOpacity(0.8),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? VocalisColors.neonTurquoise.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.15),
                width: 1,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

