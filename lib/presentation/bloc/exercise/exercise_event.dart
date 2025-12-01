part of 'exercise_bloc.dart';

abstract class ExerciseEvent extends Equatable {
  const ExerciseEvent();
  @override
  List<Object> get props => [];
}

/// Evento que se dispara al entrar en la pantalla para cargar los datos del ejercicio.
class FetchExerciseDetail extends ExerciseEvent {
  final String exerciseId;
  const FetchExerciseDetail(this.exerciseId);
}

/// Evento para reproducir el audio de referencia.
class PlayAudioRequested extends ExerciseEvent {}

/// Evento para iniciar la grabación del usuario.
class StartRecordingRequested extends ExerciseEvent {}

/// Evento para detener la grabación del usuario.
class StopRecordingRequested extends ExerciseEvent {}

/// Evento que dispara el procesamiento del audio grabado.
class ProcessRecordingRequested extends ExerciseEvent {
  final String filePath;
  const ProcessRecordingRequested(this.filePath);
}

/// Evento para reproducir el audio grabado por el usuario.
class PlayUserAudioRequested extends ExerciseEvent {}

/// Evento para detener la reproducción del audio del usuario.
class StopUserAudioRequested extends ExerciseEvent {}

/// Evento para leer las instrucciones en voz alta.
class PlayInstructionRequested extends ExerciseEvent {
  final String textToSpeak;
  const PlayInstructionRequested(this.textToSpeak);
}

/// Evento para detener y liberar todos los recursos de audio al salir de la pantalla.
class StopAudioPlayback extends ExerciseEvent {}