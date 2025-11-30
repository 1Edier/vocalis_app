import 'package:dio/dio.dart';
import '../../core/api/dio_client.dart';
import '../models/progression_map_model.dart'; // Aunque no se usa aquí, es parte del dominio
import '../models/exercise_detail_model.dart';
import '../models/user_stats_summary.dart';

class ProgressionRepository {
  final Dio _dio = DioClient.createProgressionDio();

  /// Obtiene el mapa de progreso completo para el usuario autenticado.
  Future<ProgressionMap> getProgressionMap() async {
    try {
      final response = await _dio.get('/progression/exercises/map');

      if (response.statusCode == 200) {
        return ProgressionMap.fromJson(response.data);
      } else {
        throw Exception('Error al cargar el mapa de progreso.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Error de red al obtener el progreso.');
    }
  }

  /// Inicializa el progreso de un nuevo usuario en el backend.
  Future<void> initializeProgress() async {
    try {
      await _dio.post('/progression/exercises/initialize-progress');
      print("✅ Progreso del usuario inicializado exitosamente.");
    } on DioException catch (e) {
      print("ℹ️ Información al inicializar el progreso: ${e.response?.data['detail'] ?? e.message}");
      // No relanzamos la excepción para no interrumpir el flujo.
    }
  }

  Future<ExerciseDetail> getExerciseDetail(String exerciseId) async {
    try {
      final response = await _dio.get('/progression/exercises/$exerciseId');

      if (response.statusCode == 200) {
        return ExerciseDetail.fromJson(response.data);
      } else {
        throw Exception('Error al cargar los detalles del ejercicio.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Error de red al obtener el ejercicio.');
    }
  }
  Future<UserStatsSummary> getStatsSummary() async {
    try {
      final response = await _dio.get('/progression/exercises/stats/summary');
      if (response.statusCode == 200) {
        return UserStatsSummary.fromJson(response.data);
      } else {
        throw Exception('Error al cargar las estadísticas.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Error de red al obtener estadísticas.');
    }
  }
}