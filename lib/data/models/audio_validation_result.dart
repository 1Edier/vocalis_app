import 'package:equatable/equatable.dart';

class AudioValidationResult extends Equatable {
  final bool isValid;
  final double qualityScore;
  final String recommendation;
  final bool hasBackgroundNoise;
  final bool hasClipping;

  const AudioValidationResult({
    required this.isValid,
    required this.qualityScore,
    required this.recommendation,
    required this.hasBackgroundNoise,
    required this.hasClipping,
  });

  factory AudioValidationResult.fromJson(Map<String, dynamic> json) {
    return AudioValidationResult(
      isValid: json['is_valid'] ?? false,
      qualityScore: (json['quality_score'] as num?)?.toDouble() ?? 0.0,
      recommendation: json['recommendation'] ?? 'No se pudo obtener recomendación.',
      hasBackgroundNoise: json['has_background_noise'] ?? true,
      hasClipping: json['has_clipping'] ?? true,
    );
  }

  @override
  List<Object?> get props => [isValid, qualityScore, recommendation, hasBackgroundNoise, hasClipping];
}