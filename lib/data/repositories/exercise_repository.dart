import 'package:dio/dio.dart';
import '../../core/api/dio_client.dart';
import '../models/exercise_model.dart';

class ExerciseRepository {
  final Dio _dio = DioClient.createExercisesDio();

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
      // Manejo de errores
      throw Exception(e.response?.data['message'] ?? 'Error al cargar los ejercicios.');
    }
  }
}