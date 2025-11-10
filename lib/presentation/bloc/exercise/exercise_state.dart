part of 'exercise_bloc.dart';

abstract class ExerciseState extends Equatable {
  const ExerciseState();
  @override
  List<Object?> get props => [];
}

class ExerciseInitial extends ExerciseState {}
class ExerciseLoading extends ExerciseState {}

// Estado base cuando el ejercicio está listo
abstract class ExerciseReadyState extends ExerciseState {
  final ExerciseModel exercise;
  final String? userAudioPath; // <<< NUEVO: Ruta del audio grabado por el usuario
  final bool isUserAudioPlaying; // <<< NUEVO: Controla la reproducción del audio del usuario

  const ExerciseReadyState(
      this.exercise, {
        this.userAudioPath,
        this.isUserAudioPlaying = false,
      });

  @override
  List<Object?> get props => [exercise, userAudioPath, isUserAudioPlaying];

  // Helper para copiar el estado con nuevos valores
  ExerciseReadyState copyWith({
    String? userAudioPath,
    bool? isUserAudioPlaying,
  });
}

class ExerciseReady extends ExerciseReadyState {
  const ExerciseReady(super.exercise, {super.userAudioPath, super.isUserAudioPlaying});

  @override
  ExerciseReady copyWith({String? userAudioPath, bool? isUserAudioPlaying}) {
    return ExerciseReady(
      exercise,
      userAudioPath: userAudioPath ?? this.userAudioPath,
      isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying,
    );
  }
}

class AudioPlaying extends ExerciseReadyState {
  const AudioPlaying(super.exercise, {super.userAudioPath, super.isUserAudioPlaying});

  @override
  AudioPlaying copyWith({String? userAudioPath, bool? isUserAudioPlaying}) {
    return AudioPlaying(
      exercise,
      userAudioPath: userAudioPath ?? this.userAudioPath,
      isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying,
    );
  }
}

class RecordingInProgress extends ExerciseReadyState {
  const RecordingInProgress(super.exercise, {super.userAudioPath, super.isUserAudioPlaying});

  @override
  RecordingInProgress copyWith({String? userAudioPath, bool? isUserAudioPlaying}) {
    return RecordingInProgress(
      exercise,
      userAudioPath: userAudioPath ?? this.userAudioPath,
      isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying,
    );
  }
}

class RecordingComplete extends ExerciseReadyState {
  const RecordingComplete(super.exercise, {required super.userAudioPath, super.isUserAudioPlaying});

  @override
  RecordingComplete copyWith({String? userAudioPath, bool? isUserAudioPlaying}) {
    return RecordingComplete(
      exercise,
      userAudioPath: userAudioPath ?? this.userAudioPath,
      isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying,
    );
  }
}

class ExerciseLoadFailure extends ExerciseState {}

class ValidatingAudio extends ExerciseReadyState {
  const ValidatingAudio(super.exercise, {required super.userAudioPath});

  @override
  ValidatingAudio copyWith({String? userAudioPath, bool? isUserAudioPlaying}) {
    // Implementación no necesaria ya que es un estado transitorio
    return this;
  }
}

// Estado cuando la validación es exitosa
class ValidationSuccess extends ExerciseReadyState {
  final AudioValidationResult result;
  const ValidationSuccess(super.exercise, {required super.userAudioPath, required this.result});

  @override
  ValidationSuccess copyWith({String? userAudioPath, bool? isUserAudioPlaying, AudioValidationResult? result}) {
    return ValidationSuccess(
      exercise,
      userAudioPath: userAudioPath ?? this.userAudioPath,
      result: result ?? this.result,
    );
  }
}

// Estado cuando la validación falla
class ValidationFailure extends ExerciseReadyState {
  final String error;
  const ValidationFailure(super.exercise, {required super.userAudioPath, required this.error});

  @override
  ValidationFailure copyWith({String? userAudioPath, bool? isUserAudioPlaying, String? error}) {
    return ValidationFailure(
      exercise,
      userAudioPath: userAudioPath ?? this.userAudioPath,
      error: error ?? this.error,
    );
  }
}