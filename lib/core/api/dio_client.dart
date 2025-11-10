import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- IMPORTANTE: CAMBIA ESTAS IPs POR LA IP DE TU MÁQUINA ---
const String _authBaseUrl = 'http://192.168.1.68:3001/api/v1';
const String _exercisesBaseUrl = 'http://192.168.1.68:8001/api/v1';
const String _validationBaseUrl = 'http://192.168.1.68:8001/api/v1';

class DioClient {
// LÍNEA CORREGIDA
  static final _storage = const FlutterSecureStorage();

  // Cliente para el servicio de Autenticación y Usuarios
  static Dio createAuthDio() {
    final dio = Dio(BaseOptions(baseUrl: _authBaseUrl));

    // Interceptor para añadir el token a las cabeceras automáticamente
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
    return dio;
  }

  // Cliente para el servicio de Ejercicios
  static Dio createExercisesDio() {
    final dio = Dio(BaseOptions(baseUrl: _exercisesBaseUrl));
    // Por ahora no necesita interceptor de token, pero podría añadirse si es necesario
    return dio;
  }

  static Dio createValidationDio() {
    final dio = Dio(BaseOptions(baseUrl: _validationBaseUrl));
    // Podría necesitar un token de autenticación en el futuro
    return dio;
  }
}