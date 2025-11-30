import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LockedCategoryScreen extends StatelessWidget {
  final String categoryName;
  final String previousCategoryName;

  const LockedCategoryScreen({
    super.key,
    required this.categoryName,
    required this.previousCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- AQUÍ ESTÁ LA MODIFICACIÓN ---
            Lottie.asset(
              'assets/lottie/door_locked_animation.json',
              width: 250,
              height: 250,
              // La propiedad 'repeat' en 'true' hace que la animación se reproduzca en bucle.
              repeat: true,
            ),
            const SizedBox(height: 24),
            Text(
              '¡Aún no puedes acceder a "$categoryName"!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 12),
            Text(
              'Completa todos los ejercicios de la sección "$previousCategoryName" para desbloquear este camino.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}