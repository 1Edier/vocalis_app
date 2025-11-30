import 'package:equatable/equatable.dart';

// Sub-modelo para los scores detallados
class Scores extends Equatable {
  final double pronunciation;
  final double fluency;
  final double rhythm;
  final double overall;

  const Scores({required this.pronunciation, required this.fluency, required this.rhythm, required this.overall});

  factory Scores.fromJson(Map<String, dynamic> json) {
    return Scores(
      pronunciation: (json['pronunciation'] as num?)?.toDouble() ?? 0.0,
      fluency: (json['fluency'] as num?)?.toDouble() ?? 0.0,
      rhythm: (json['rhythm'] as num?)?.toDouble() ?? 0.0,
      overall: (json['overall'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [pronunciation, fluency, rhythm, overall];
}

// Sub-modelo para el feedback
class FeedbackDetail extends Equatable {
  final String mainMessage;
  final List<String> strengths;
  final List<String> areasToImprove;

  const FeedbackDetail({required this.mainMessage, required this.strengths, required this.areasToImprove});

  factory FeedbackDetail.fromJson(Map<String, dynamic> json) {
    return FeedbackDetail(
      mainMessage: json['main_message'] ?? '¡Sigue practicando!',
      strengths: List<String>.from(json['strengths'] ?? []),
      areasToImprove: List<String>.from(json['areas_to_improve'] ?? []),
    );
  }

  @override
  List<Object?> get props => [mainMessage, strengths, areasToImprove];
}

// Sub-modelo para el resultado de la progresión
class ProgressionResult extends Equatable {
  final bool progressUpdated;
  final int starsEarned;
  final bool unlockedNext;

  const ProgressionResult({required this.progressUpdated, required this.starsEarned, required this.unlockedNext});

  factory ProgressionResult.fromJson(Map<String, dynamic> json) {
    return ProgressionResult(
      progressUpdated: json['progress_updated'] ?? false,
      starsEarned: json['stars_earned'] ?? 0,
      unlockedNext: json['unlocked_next'] ?? false,
    );
  }

  @override
  List<Object?> get props => [progressUpdated, starsEarned, unlockedNext];
}

// --- MODELO PRINCIPAL ---
class ProcessAudioResult extends Equatable {
  final Scores scores;
  final FeedbackDetail feedback;
  final ProgressionResult progression;

  // Getters para facilitar el acceso desde la UI
  bool get isCompleted => (scores.overall >= 70.0);
  int get stars => progression.starsEarned;

  const ProcessAudioResult({required this.scores, required this.feedback, required this.progression});

  factory ProcessAudioResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ProcessAudioResult(
      scores: Scores.fromJson(data['scores'] ?? {}),
      feedback: FeedbackDetail.fromJson(data['feedback'] ?? {}),
      progression: ProgressionResult.fromJson(data['progression'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [scores, feedback, progression];
}