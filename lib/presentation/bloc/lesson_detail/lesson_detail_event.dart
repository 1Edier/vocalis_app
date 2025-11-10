part of 'lesson_detail_bloc.dart';

abstract class LessonDetailEvent extends Equatable {
  const LessonDetailEvent();
  @override
  List<Object> get props => [];
}

// Evento renombrado para mayor claridad
class FetchExercisesForLevel extends LessonDetailEvent {
  final String category;
  final int level;
  const FetchExercisesForLevel({required this.category, required this.level});
}