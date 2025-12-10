// lib/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // El BlocListener ya no es necesario aquí.
    // La lógica de redirección en app_router.dart maneja la navegación.
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}