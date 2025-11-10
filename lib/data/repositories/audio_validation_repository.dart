import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/api/dio_client.dart';
import '../models/audio_validation_result.dart';

class AudioValidationRepository {
  final Dio _dio = DioClient.createValidationDio();

  Future<AudioValidationResult> validateAudio(String filePath) async {
    try {
      // 1. Lee el archivo y lo codifica en Base64
      final file = File(filePath);
      final audioBytes = await file.readAsBytes();
      final String base64String = base64Encode(audioBytes);

      // 2. Prepara el cuerpo del JSON
      final Map<String, dynamic> body = {
        'audio_base64': base64String,
      };

      // 3. Envía la solicitud POST
      final response = await _dio.post('/audio/validate-quality', data: body);

      // 4. Parsea la respuesta y la devuelve
      if (response.statusCode == 200 && response.data['success'] == true) {
        return AudioValidationResult.fromJson(response.data['data']);
      } else {
        throw Exception('El servidor respondió con un error.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error de red al validar el audio.');
    }
  }
}