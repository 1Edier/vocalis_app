import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _myLocalIp = '192.168.1.68'; // <<< ¡RECUERDA PONER TU IP AQUÍ!

const String _authBaseUrl = 'https://api-gateway.politecoast-4396a3db.eastus.azurecontainerapps.io/api/v1';
const String _exercisesBaseUrl = 'https://api-gateway.politecoast-4396a3db.eastus.azurecontainerapps.io/api/v1';
const String _validationBaseUrl = 'https://api-gateway.politecoast-4396a3db.eastus.azurecontainerapps.io/api/v1';

class DioClient {
  static final _storage = const FlutterSecureStorage();

  // Interceptor reutilizable para añadir el token
  static InterceptorsWrapper _getAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    );
  }

  static Dio createAuthDio() {
    final dio = Dio(BaseOptions(baseUrl: _authBaseUrl));
    dio.interceptors.add(_getAuthInterceptor());
    return dio;
  }

  // --- CORRECCIÓN ---
  // El cliente de ejercicios ahora también necesita el token de autenticación.
  static Dio createExercisesDio() {
    final dio = Dio(BaseOptions(baseUrl: _exercisesBaseUrl));
    dio.interceptors.add(_getAuthInterceptor());
    return dio;
  }

  static Dio createValidationDio() {
    final dio = Dio(BaseOptions(baseUrl: _validationBaseUrl));
    // Este servicio también requiere autenticación, así que le añadimos el interceptor.
    dio.interceptors.add(_getAuthInterceptor()); // <<< LÍNEA AÑADIDA
    return dio;
  }
  static Dio createProgressionDio() {
    final dio = Dio(BaseOptions(baseUrl: _exercisesBaseUrl));
    // Este servicio necesita el token de autenticación
    dio.interceptors.add(_getAuthInterceptor());
    return dio;
  }
}