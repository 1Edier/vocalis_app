part of 'exercise_bloc.dart';

abstract class ExerciseEvent extends Equatable {
  const ExerciseEvent();
  @override
  List<Object> get props => [];
}

class FetchExerciseDetail extends ExerciseEvent {
  final String exerciseId;
  const FetchExerciseDetail(this.exerciseId);
}

class PlayAudioRequested extends ExerciseEvent {}
class StartRecordingRequested extends ExerciseEvent {}
class StopRecordingRequested extends ExerciseEvent {}

// Renombrado de 'Validate' a 'Process'
class ProcessRecordingRequested extends ExerciseEvent {
  final String filePath;
  const ProcessRecordingRequested(this.filePath);
}

class PlayUserAudioRequested extends ExerciseEvent {}
class StopUserAudioRequested extends ExerciseEvent {}

class PlayInstructionRequested extends ExerciseEvent {
  final String textToSpeak;
  const PlayInstructionRequested(this.textToSpeak);
}