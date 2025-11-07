part of 'exercise_bloc.dart';

abstract class ExerciseEvent extends Equatable {
  const ExerciseEvent();
  @override
  List<Object> get props => [];
}

class FetchExercise extends ExerciseEvent {
  final String lessonId;
  const FetchExercise(this.lessonId);
}

class PlayAudioRequested extends ExerciseEvent {}
class StartRecordingRequested extends ExerciseEvent {}
class StopRecordingRequested extends ExerciseEvent {}
class SubmitAnswer extends ExerciseEvent {}