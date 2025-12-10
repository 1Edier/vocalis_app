import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _myLocalIp = '192.168.1.68';

const String _BaseUrl = 'https://api-gateway.politecoast-4396a3db.eastus.azurecontainerapps.io/api/v1';


class DioClient {
  static final _storage = const FlutterSecureStorage();
  
  // Callback para manejar la expiración del token
  static void Function()? onTokenExpired;

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
      onError: (DioException error, handler) async {
        // Si recibimos un error 401 (Unauthorized), el token expiró o es inválido
        if (error.response?.statusCode == 401) {
          // Eliminamos el token inválido
          await _storage.delete(key: 'accessToken');
          
          // Notificamos que el token expiró
          if (onTokenExpired != null) {
            onTokenExpired!();
          }
        }
        return handler.next(error);
      },
    );
  }

  static Dio createAuthDio() {
    final dio = Dio(BaseOptions(baseUrl: _BaseUrl));
    dio.interceptors.add(_getAuthInterceptor());
    return dio;
  }

  // --- CORRECCIÓN ---
  // El cliente de ejercicios ahora también necesita el token de autenticación.
  static Dio createExercisesDio() {
    final dio = Dio(BaseOptions(baseUrl: _BaseUrl));
    dio.interceptors.add(_getAuthInterceptor());
    return dio;
  }

  static Dio createValidationDio() {
    final dio = Dio(BaseOptions(baseUrl: _BaseUrl));

    dio.interceptors.add(_getAuthInterceptor());
    return dio;
  }
  static Dio createProgressionDio() {
    final dio = Dio(BaseOptions(baseUrl: _BaseUrl));
    // Este servicio necesita el token de autenticación
    dio.interceptors.add(_getAuthInterceptor());
    return dio;
  }
}