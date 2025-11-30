import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import '../../core/api/dio_client.dart';
import '../models/process_audio_result.dart';

class AudioProcessingRepository {
  final Dio _dio = DioClient.createValidationDio();

  Future<ProcessAudioResult> processAudio({
    required String filePath,
    required String exerciseId,
    required String referenceText,
  }) async {
    try {
      final file = File(filePath);
      final audioBytes = await file.readAsBytes();
      final String base64String = base64Encode(audioBytes);

      final metadata = await _getDeviceMetadata();

      final Map<String, dynamic> body = {
        'audio_base64': base64String,
        'exercise_id': exerciseId,
        'metadata': metadata,
        'reference_text': referenceText,
      };

      final response = await _dio.post('/audio/process', data: body);

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        // Llama al nuevo constructor FromJson que mapea la estructura completa
        return ProcessAudioResult.fromJson(response.data);
      } else {
        throw Exception('Respuesta inesperada del servidor.');
      }
    } on DioException catch (e) {
      String errorMessage = "Error de red al procesar el audio.";
      if (e.response?.data is Map) {
        errorMessage = e.response!.data['detail'] ?? e.response!.data['message'] ?? errorMessage;
      } else if (e.message != null && e.message!.isNotEmpty) {
        errorMessage = e.message!;
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Ocurrió un error inesperado: ${e.toString()}");
    }
  }

  Future<Map<String, String>> _getDeviceMetadata() async {
    final deviceInfo = DeviceInfoPlugin();
    String device = 'Unknown';
    String os = 'Unknown';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        device = androidInfo.model;
        os = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        device = iosInfo.utsname.machine;
        os = 'iOS ${iosInfo.systemVersion}';
      }
    } catch(e) {
      device = 'Error getting device info';
      os = 'Unknown';
    }

    return {'app_version': '1.0.0', 'device': device, 'os': os};
  }
}