part of 'exercise_bloc.dart';

abstract class ExerciseEvent extends Equatable {
  const ExerciseEvent();
  @override
  List<Object> get props => [];
}

class InitializeExercise extends ExerciseEvent {
  final ExerciseModel exercise;
  const InitializeExercise(this.exercise);
}

class PlayAudioRequested extends ExerciseEvent {}
class StartRecordingRequested extends ExerciseEvent {}
class StopRecordingRequested extends ExerciseEvent {}

// --- NUEVOS EVENTOS ---
class PlayUserAudioRequested extends ExerciseEvent {}
class StopUserAudioRequested extends ExerciseEvent {}
class ValidateRecordingRequested extends ExerciseEvent {
  final String filePath;
  const ValidateRecordingRequested(this.filePath);
}