import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Una clase de ayuda para mostrar y ocultar un overlay de carga global.
class LoadingOverlay {
  static OverlayEntry? _overlay;

  /// Muestra el overlay de carga con la animación de Lottie.
  static void show(BuildContext context) {
    // Si ya hay un overlay mostrándose, no hacemos nada.
    if (_overlay != null) return;

    _overlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Fondo semi-transparente para atenuar la pantalla de abajo
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // La animación de Lottie centrada
          Center(
            child: Lottie.asset(
              'assets/lottie/loading_cat.json', // <-- El nombre de tu archivo
              width: 200,
              height: 200,
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlay!);
  }

  /// Oculta el overlay de carga si está visible.
  static void hide() {
    _overlay?.remove();
    _overlay = null;
  }
}