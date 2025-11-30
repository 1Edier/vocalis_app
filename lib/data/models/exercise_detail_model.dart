import 'package:equatable/equatable.dart';

class ExerciseDetail extends Equatable {
  final String id;
  final String exerciseId;
  final int orderIndex; // Añadido para mostrar el nivel
  final String title;
  final String category;
  final String subcategory;
  final String textContent;
  final int difficultyLevel;
  final String referenceAudioUrl;
  final List<String> tips;
  final String status;
  final int unlockScoreRequired;
  final double bestScore;

  const ExerciseDetail({
    required this.id,
    required this.exerciseId,
    required this.orderIndex,
    required this.title,
    required this.category,
    required this.subcategory,
    required this.textContent,
    required this.difficultyLevel,
    required this.referenceAudioUrl,
    required this.tips,
    required this.status,
    required this.unlockScoreRequired,
    required this.bestScore,
  });

  factory ExerciseDetail.fromJson(Map<String, dynamic> json) {
    final tipsList = (json['tips'] as List<dynamic>?)?.map((tip) => tip.toString()).toList() ?? [];

    return ExerciseDetail(
      id: json['id'] ?? '',
      exerciseId: json['exercise_id'] ?? '',
      orderIndex: json['order_index'] ?? 1,
      title: json['title'] ?? 'Sin Título',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      textContent: json['text_content'] ?? '',
      difficultyLevel: json['difficulty_level'] ?? 1,
      referenceAudioUrl: json['reference_audio_s3_url'] ?? '',
      tips: tipsList,
      status: json['user_progress']?['status'] ?? 'locked',
      unlockScoreRequired: json['unlock_score_required'] ?? 70,
      bestScore: (json['user_progress']?['best_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, exerciseId, orderIndex, title, textContent, referenceAudioUrl, tips, status, unlockScoreRequired, bestScore];
}