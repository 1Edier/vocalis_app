import 'package:equatable/equatable.dart';

class ExerciseModel extends Equatable {
  final String id;
  final String phoneme;
  final String word;
  final String audioUrl; // URL del audio a reproducir
  final String avatarUrl; // URL de la imagen del avatar

  const ExerciseModel({
    required this.id,
    required this.phoneme,
    required this.word,
    required this.audioUrl,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, phoneme, word, audioUrl, avatarUrl];
}