part of 'exercise_bloc.dart';

abstract class ExerciseState extends Equatable {
  const ExerciseState();
  @override
  List<Object?> get props => [];
}

class ExerciseInitial extends ExerciseState {}
class ExerciseLoading extends ExerciseState {}
class ExerciseLoadFailure extends ExerciseState {}

abstract class ExerciseReadyState extends ExerciseState {
  final ExerciseDetail exercise;
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

  ExerciseReadyState copyWith({
    ExerciseDetail? exercise,
    String? userAudioPath,
    bool? isUserAudioPlaying,
    bool? isInstructionSpeaking,
  });
}

class ExerciseReady extends ExerciseReadyState {
  const ExerciseReady(super.exercise, {super.userAudioPath, super.isUserAudioPlaying, super.isInstructionSpeaking});

  @override
  ExerciseReady copyWith({ExerciseDetail? exercise, String? userAudioPath, bool? isUserAudioPlaying, bool? isInstructionSpeaking}) {
    return ExerciseReady(exercise ?? this.exercise, userAudioPath: userAudioPath ?? this.userAudioPath, isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying, isInstructionSpeaking: isInstructionSpeaking ?? this.isInstructionSpeaking);
  }
}

class AudioPlaying extends ExerciseReadyState {
  const AudioPlaying(super.exercise, {super.userAudioPath, super.isUserAudioPlaying, super.isInstructionSpeaking});

  @override
  AudioPlaying copyWith({ExerciseDetail? exercise, String? userAudioPath, bool? isUserAudioPlaying, bool? isInstructionSpeaking}) {
    return AudioPlaying(exercise ?? this.exercise, userAudioPath: userAudioPath ?? this.userAudioPath, isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying, isInstructionSpeaking: isInstructionSpeaking ?? this.isInstructionSpeaking);
  }
}

class RecordingInProgress extends ExerciseReadyState {
  const RecordingInProgress(super.exercise, {super.userAudioPath, super.isUserAudioPlaying, super.isInstructionSpeaking});

  @override
  RecordingInProgress copyWith({ExerciseDetail? exercise, String? userAudioPath, bool? isUserAudioPlaying, bool? isInstructionSpeaking}) {
    return RecordingInProgress(exercise ?? this.exercise, userAudioPath: userAudioPath ?? this.userAudioPath, isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying, isInstructionSpeaking: isInstructionSpeaking ?? this.isInstructionSpeaking);
  }
}

class RecordingComplete extends ExerciseReadyState {
  const RecordingComplete(super.exercise, {required String userAudioPath, super.isUserAudioPlaying, super.isInstructionSpeaking}) : super(userAudioPath: userAudioPath);

  @override
  RecordingComplete copyWith({ExerciseDetail? exercise, String? userAudioPath, bool? isUserAudioPlaying, bool? isInstructionSpeaking}) {
    return RecordingComplete(exercise ?? this.exercise, userAudioPath: userAudioPath ?? this.userAudioPath!, isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying, isInstructionSpeaking: isInstructionSpeaking ?? this.isInstructionSpeaking);
  }
}

// Renombrados de 'Validation' a 'Processing'
class ProcessingAudio extends ExerciseReadyState {
  const ProcessingAudio(super.exercise, {required String userAudioPath, super.isUserAudioPlaying, super.isInstructionSpeaking}) : super(userAudioPath: userAudioPath);
  @override
  ProcessingAudio copyWith({ExerciseDetail? exercise, String? userAudioPath, bool? isUserAudioPlaying, bool? isInstructionSpeaking}) {
    return ProcessingAudio(exercise ?? this.exercise, userAudioPath: userAudioPath ?? this.userAudioPath!, isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying, isInstructionSpeaking: isInstructionSpeaking ?? this.isInstructionSpeaking);
  }
}

class ProcessingSuccess extends ExerciseReadyState {
  final ProcessAudioResult result;
  const ProcessingSuccess(super.exercise, {required String userAudioPath, required this.result, super.isUserAudioPlaying, super.isInstructionSpeaking}) : super(userAudioPath: userAudioPath);
  @override
  ProcessingSuccess copyWith({ExerciseDetail? exercise, String? userAudioPath, bool? isUserAudioPlaying, bool? isInstructionSpeaking, ProcessAudioResult? result}) {
    return ProcessingSuccess(exercise ?? this.exercise, userAudioPath: userAudioPath ?? this.userAudioPath!, result: result ?? this.result, isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying, isInstructionSpeaking: isInstructionSpeaking ?? this.isInstructionSpeaking);
  }
  @override
  List<Object?> get props => super.props..add(result);
}

class ProcessingFailure extends ExerciseReadyState {
  final String error;
  const ProcessingFailure(super.exercise, {String? userAudioPath, required this.error, super.isUserAudioPlaying, super.isInstructionSpeaking}) : super(userAudioPath: userAudioPath);
  @override
  ProcessingFailure copyWith({ExerciseDetail? exercise, String? userAudioPath, bool? isUserAudioPlaying, bool? isInstructionSpeaking, String? error}) {
    return ProcessingFailure(exercise ?? this.exercise, userAudioPath: userAudioPath ?? this.userAudioPath, error: error ?? this.error, isUserAudioPlaying: isUserAudioPlaying ?? this.isUserAudioPlaying, isInstructionSpeaking: isInstructionSpeaking ?? this.isInstructionSpeaking);
  }
  @override
  List<Object?> get props => super.props..add(error);
}