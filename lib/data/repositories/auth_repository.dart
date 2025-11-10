import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api/dio_client.dart';
import '../models/user_model.dart';
import '../../core/api/dio_client.dart';

class AuthRepository {
  final Dio _dio = DioClient.createAuthDio();
  final _storage = const FlutterSecureStorage();

  // Intenta obtener el perfil del usuario si hay un token guardado
  Future<UserModel?> tryAutoLogin() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) {
      return null; // No hay sesión guardada
    }
    try {
      return await getProfile();
    } catch (e) {
      // El token podría ser inválido/expirado, lo borramos
      await logout();
      return null;
    }
  }

  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['accessToken'];
      if (token == null) {
        throw Exception('Token no recibido del servidor.');
      }

      await _storage.write(key: 'accessToken', value: token);

      // Después de iniciar sesión y guardar el token, obtenemos el perfil del usuario
      return await getProfile();

    } on DioException catch (e) {
      // Manejar errores específicos de la API (ej: 401 Credenciales inválidas)
      throw Exception(e.response?.data['message'] ?? 'Error de red.');
    }
  }

  Future<void> signUp({
    required String fullName,
    required int age,
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {
          'fullName': fullName,
          'age': age,
          'email': email,
          'password': password,
        },
      );
      // El registro fue exitoso, no devuelve token, el usuario debe hacer login
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al registrarse.');
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get('/users/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener el perfil.');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
  }
}