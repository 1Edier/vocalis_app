import 'package:dio/dio.dart';
import '../../core/api/dio_client.dart';
import '../models/exercise_model.dart';

class ExerciseRepository {
  final Dio _dio = DioClient.createExercisesDio();

  /// Obtiene una lista de ejercicios basada en filtros.
  Future<List<ExerciseModel>> getExercises({
    required String category,
    required int difficultyLevel,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/exercises',
        queryParameters: {
          'category': category,
          'difficulty_level': difficultyLevel,
          'is_active': true,
          'limit': limit,
          'offset': offset,
        },
      );

      final List<dynamic> exerciseListJson = response.data['exercises'];

      return exerciseListJson.map((json) => ExerciseModel.fromJson(json)).toList();

    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al cargar los ejercicios.');
    }
  }

  /// Inicializa el progreso de un nuevo usuario en el backend.
  /// Esta llamada se realiza en segundo plano y no bloquea al usuario.
  Future<void> initializeProgress() async {
    try {
      // Realiza una petición POST sin cuerpo (body).
      // El token de autorización se añade automáticamente por el interceptor de Dio.
      await _dio.post('/exercises/initialize-progress');
      print("✅ Progreso del usuario inicializado exitosamente.");
    } on DioException catch (e) {
      // Si el progreso ya existe, la API podría devolver un error (ej. 409 Conflict).
      // Es seguro ignorar este error ya que no afecta al usuario.
      print("ℹ️ Información al inicializar el progreso del usuario: ${e.response?.data['detail'] ?? e.message}");
      // No relanzamos la excepción para no interrumpir el flujo de inicio de sesión.
    }
  }
}