part of 'exercise_bloc.dart';

abstract class ExerciseState extends Equatable {
  const ExerciseState();
  @override
  List<Object?> get props => [];
}

class ExerciseInitial extends ExerciseState {}
class ExerciseLoading extends ExerciseState {}

// --- ESTADO BASE ---
// Contiene todos los datos comunes que persisten a través de los diferentes estados de la pantalla.
abstract class ExerciseReadyState extends ExerciseState {
  final ExerciseModel exercise;
  final String? userAudioPath;
  final bool isUserAudioPlaying;
  final bool isInstructionSpeaking;

  const ExerciseReadyState(
      this.exercise, {
        this.userAudioPath,
        this.isUserAudioPlaying = false,
        this.isInstructionSpeaking = false,
      });

  @override
  List<Object?> get props => [exercise, userAudioPath, isUserAudioPlaying, isInstructionSpeaking];

  // Método abstracto que obliga a las clases hijas a implementar una forma de copiar el estado.
  ExerciseReadyState copyWith({
    String? userAudioPath,
    bool? isUserAudioPlaying,
    bool? isInstructionSpeaking,
  });
}

// --- ESTADOS ESPECÍFICOS ---

// Estado por defecto cuando la pantalla está lista para interactuar.
class ExerciseReady extends ExerciseReadyState {
  const ExerciseReady(super.exercise, {super.userAudioPath, super.isUserAudioPlaying, super.isInstructionSpeaking});

  @override
  ExerciseReady copyWith({String? userAudioPath, bool? isUserAudioPlaying, bool? isInstructionSpeaking}) {
    return ExerciseReady(
      exercise,
      userAudioPath: userAudioPath ?? this.userAudioPath,
      isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying,
      isInstructionSpeaking: isInstructionSpeaking ?? this.isInstructionSpeaking,
    );
  }
}

// Estado mientras se reproduce el audio de referencia.
class AudioPlaying extends ExerciseReadyState {
  const AudioPlaying(super.exercise, {super.userAudioPath, super.isUserAudioPlaying, super.isInstructionSpeaking});

  @override
  AudioPlaying copyWith({String? userAudioPath, bool? isUserAudioPlaying, bool? isInstructionSpeaking}) {
    return AudioPlaying(
      exercise,
      userAudioPath: userAudioPath ?? this.userAudioPath,
      isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying,
      isInstructionSpeaking: isInstructionSpeaking ?? this.isInstructionSpeaking,
    );
  }
}

// Estado mientras se graba el audio del usuario.
class RecordingInProgress extends ExerciseReadyState {
  const RecordingInProgress(super.exercise, {super.userAudioPath, super.isUserAudioPlaying, super.isInstructionSpeaking});

  @override
  RecordingInProgress copyWith({String? userAudioPath, bool? isUserAudioPlaying, bool? isInstructionSpeaking}) {
    return RecordingInProgress(
      exercise,
      userAudioPath: userAudioPath ?? this.userAudioPath,
      isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying,
      isInstructionSpeaking: isInstructionSpeaking ?? this.isInstructionSpeaking,
    );
  }
}

// Estado transitorio justo después de que la grabación se completa (antes de la validación).
class RecordingComplete extends ExerciseReadyState {
  const RecordingComplete(super.exercise, {required super.userAudioPath, super.isUserAudioPlaying, super.isInstructionSpeaking});

  @override
  RecordingComplete copyWith({String? userAudioPath, bool? isUserAudioPlaying, bool? isInstructionSpeaking}) {
    return RecordingComplete(
      exercise,
      userAudioPath: userAudioPath ?? this.userAudioPath!,
      isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying,
      isInstructionSpeaking: isInstructionSpeaking ?? this.isInstructionSpeaking,
    );
  }
}

// Estado mientras se valida el audio con la API.
class ValidatingAudio extends ExerciseReadyState {
  const ValidatingAudio(super.exercise, {required super.userAudioPath, super.isUserAudioPlaying, super.isInstructionSpeaking});

  @override
  ValidatingAudio copyWith({String? userAudioPath, bool? isUserAudioPlaying, bool? isInstructionSpeaking}) {
    return ValidatingAudio(
      exercise,
      userAudioPath: userAudioPath ?? this.userAudioPath!,
      isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying,
      isInstructionSpeaking: isInstructionSpeaking ?? this.isInstructionSpeaking,
    );
  }
}

// Estado cuando la validación es exitosa.
class ValidationSuccess extends ExerciseReadyState {
  final AudioValidationResult result;
  const ValidationSuccess(super.exercise, {required super.userAudioPath, required this.result, super.isUserAudioPlaying, super.isInstructionSpeaking});

  @override
  ValidationSuccess copyWith({String? userAudioPath, bool? isUserAudioPlaying, bool? isInstructionSpeaking, AudioValidationResult? result}) {
    return ValidationSuccess(
      exercise,
      userAudioPath: userAudioPath ?? this.userAudioPath!,
      result: result ?? this.result,
      isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying,
      isInstructionSpeaking: isInstructionSpeaking ?? this.isInstructionSpeaking,
    );
  }

  @override
  List<Object?> get props => super.props..add(result);
}

// Estado cuando la validación falla.
class ValidationFailure extends ExerciseReadyState {
  final String error;
  const ValidationFailure(super.exercise, {required super.userAudioPath, required this.error, super.isUserAudioPlaying, super.isInstructionSpeaking});

  @override
  ValidationFailure copyWith({String? userAudioPath, bool? isUserAudioPlaying, bool? isInstructionSpeaking, String? error}) {
    return ValidationFailure(
      exercise,
      userAudioPath: userAudioPath ?? this.userAudioPath!,
      error: error ?? this.error,
      isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying,
      isInstructionSpeaking: isInstructionSpeaking ?? this.isInstructionSpeaking,
    );
  }

  @override
  List<Object?> get props => super.props..add(error);
}

// Estado si falla la carga inicial del ejercicio.
class ExerciseLoadFailure extends ExerciseState {}