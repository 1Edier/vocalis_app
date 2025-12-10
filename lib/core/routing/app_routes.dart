// lib/core/routing/app_routes.dart
class AppRoutes {
  // Static routes
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';

  // Shell route for main navigation (los que tienen la barra de navegación inferior)
  static const homeMap = '/map';
  static const homeProfile = '/profile';

  // Dynamic route for exercise details (pantalla completa sin barra de navegación)
  static const exercise = '/exercise/:exerciseId';

  // Helper method to build the exercise detail path easily
  static String exerciseDetail(String exerciseId) => '/exercise/$exerciseId';
}