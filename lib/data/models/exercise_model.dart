import 'package:equatable/equatable.dart';

class ExerciseModel extends Equatable {

  final String id;
  final String category;
  final String subcategory;
  final String textContent;
  final int difficultyLevel;
  final String referenceAudioUrl;
  final bool isActive;


  const ExerciseModel({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.textContent,
    required this.difficultyLevel,
    required this.referenceAudioUrl,
    required this.isActive,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      textContent: json['text_content'] ?? 'Sin texto',
      difficultyLevel: json['difficulty_level'] ?? 1,
      referenceAudioUrl: json['reference_audio_url'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, category, subcategory, textContent, difficultyLevel, referenceAudioUrl, isActive];
}