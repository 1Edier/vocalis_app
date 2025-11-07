part of 'exercise_bloc.dart';

abstract class ExerciseState extends Equatable {
  const ExerciseState();
  @override
  List<Object> get props => [];
}

class ExerciseInitial extends ExerciseState {}
class ExerciseLoading extends ExerciseState {}

// Estado base cuando el ejercicio está listo para ser interactuado
abstract class ExerciseReadyState extends ExerciseState {
  final ExerciseModel exercise;
  const ExerciseReadyState(this.exercise);
  @override
  List<Object> get props => [exercise];
}

class ExerciseReady extends ExerciseReadyState {
  const ExerciseReady(super.exercise);
}

class AudioPlaying extends ExerciseReadyState {
  const AudioPlaying(super.exercise);
}

class RecordingInProgress extends ExerciseReadyState {
  const RecordingInProgress(super.exercise);
}

class RecordingComplete extends ExerciseReadyState {
  const RecordingComplete(super.exercise);
}

class ExerciseFinished extends ExerciseState {}
class ExerciseLoadFailure extends ExerciseState {}