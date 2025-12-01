import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../data/models/process_audio_result.dart';
import '../../../data/models/exercise_detail_model.dart';
import '../../../data/repositories/audio_processing_repository.dart';
import '../../../data/repositories/progression_repository.dart';

part 'exercise_event.dart';
part 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final ProgressionRepository _progressionRepository;
  final AudioProcessingRepository _audioProcessingRepository = AudioProcessingRepository();

  final _audioRecorder = AudioRecorder();
  final _referenceAudioPlayer = AudioPlayer();
  final _userAudioPlayer = AudioPlayer();
  final _flutterTts = FlutterTts();

  ExerciseBloc({required ProgressionRepository progressionRepository})
      : _progressionRepository = progressionRepository,
        super(ExerciseInitial()) {
    _initializeTts();
    _userAudioPlayer.onPlayerStateChanged.listen((state) {
      if ((state == PlayerState.completed || state == PlayerState.stopped) && this.state is ExerciseReadyState) {
        if ((this.state as ExerciseReadyState).isUserAudioPlaying) {
          add(StopUserAudioRequested());
        }
      }
    });

    on<FetchExerciseDetail>(_onFetchExerciseDetail);
    on<PlayAudioRequested>(_onPlayAudio);
    on<StartRecordingRequested>(_onStartRecording);
    on<StopRecordingRequested>(_onStopRecording);
    on<ProcessRecordingRequested>(_onProcessRecording);
    on<PlayUserAudioRequested>(_onPlayUserAudio);
    on<StopUserAudioRequested>(_onStopUserAudio);
    on<PlayInstructionRequested>(_onPlayInstruction);
    on<StopAudioPlayback>(_onStopAudioPlayback);
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _onFetchExerciseDetail(FetchExerciseDetail event, Emitter<ExerciseState> emit) async {
    emit(ExerciseLoading());
    try {
      final exerciseDetail = await _progressionRepository.getExerciseDetail(event.exerciseId);
      emit(ExerciseReady(exerciseDetail));
    } catch (e) {
      emit(ExerciseLoadFailure());
    }
  }

  Future<void> _onPlayAudio(PlayAudioRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      await _flutterTts.stop();
      await _userAudioPlayer.stop();
      await _audioRecorder.stop();

      emit(AudioPlaying(currentState.exercise, userAudioPath: currentState.userAudioPath));
      try {
        await _referenceAudioPlayer.play(UrlSource(currentState.exercise.referenceAudioUrl));
        await _referenceAudioPlayer.onPlayerComplete.first;
      } catch (e) {
        emit(ProcessingFailure(currentState.exercise, userAudioPath: currentState.userAudioPath, error: "No se pudo reproducir el audio de referencia."));
      } finally {
        if (this.state is AudioPlaying) {
          final currentPlayingState = this.state as AudioPlaying;
          emit(ExerciseReady(
            currentPlayingState.exercise,
            userAudioPath: currentPlayingState.userAudioPath,
            isUserAudioPlaying: false,
            isInstructionSpeaking: false,
          ));
        }
      }
    }
  }

  Future<void> _onStartRecording(StartRecordingRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      try {
        await _referenceAudioPlayer.stop();
        await _userAudioPlayer.stop();
        await _flutterTts.stop();

        if (await _audioRecorder.hasPermission()) {
          final tempDir = await getTemporaryDirectory();
          final path = '${tempDir.path}/user_recording.wav';
          const config = RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1);
          await _audioRecorder.start(config, path: path);
          emit(RecordingInProgress(currentState.exercise, userAudioPath: currentState.userAudioPath));
        } else {
          emit(ProcessingFailure(currentState.exercise, userAudioPath: currentState.userAudioPath, error: "Permiso de micrófono denegado. Por favor, actívalo en los ajustes de la aplicación."));
        }
      } catch (e) {
        emit(ProcessingFailure(currentState.exercise, userAudioPath: currentState.userAudioPath, error: "Error al iniciar grabación: ${e.toString()}"));
      }
    }
  }

  Future<void> _onStopRecording(StopRecordingRequested event, Emitter<ExerciseState> emit) async {
    if (state is RecordingInProgress) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        add(ProcessRecordingRequested(path));
      }
    }
  }

  Future<void> _onProcessRecording(ProcessRecordingRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      emit(ProcessingAudio(currentState.exercise, userAudioPath: event.filePath));
      try {
        final result = await _audioProcessingRepository.processAudio(
          filePath: event.filePath,
          exerciseId: currentState.exercise.exerciseId,
          referenceText: currentState.exercise.textContent,
        );
        emit(ProcessingSuccess(currentState.exercise, userAudioPath: event.filePath, result: result));

        await _speakFeedback(result.feedback);

      } catch (e) {
        final errorMessage = e.toString().replaceFirst("Exception: ", "");
        emit(ProcessingFailure(currentState.exercise, userAudioPath: event.filePath, error: errorMessage));

        // --- CORRECCIÓN CLAVE: LEER EL MENSAJE DE ERROR ---
        // Después de emitir el estado de fallo, leemos el error en voz alta.
        await _flutterTts.stop(); // Detiene cualquier audio anterior
        await _flutterTts.speak("Hubo un problema. $errorMessage");
        await _flutterTts.awaitSpeakCompletion(true);
      }
    }
  }
  Future<void> _speakFeedback(FeedbackDetail feedback) async {
    await _referenceAudioPlayer.stop();
    await _userAudioPlayer.stop();

    await _flutterTts.speak(feedback.mainMessage);
    await _flutterTts.awaitSpeakCompletion(true);

    if (feedback.strengths.isNotEmpty) {
      await _flutterTts.speak("Tus puntos fuertes son:");
      await _flutterTts.awaitSpeakCompletion(true);
      for (final strength in feedback.strengths) {
        await _flutterTts.speak(strength);
        await _flutterTts.awaitSpeakCompletion(true);
      }
    }

    if (feedback.areasToImprove.isNotEmpty) {
      await _flutterTts.speak("Tus áreas a mejorar son:");
      await _flutterTts.awaitSpeakCompletion(true);
      for (final area in feedback.areasToImprove) {
        await _flutterTts.speak(area);
        await _flutterTts.awaitSpeakCompletion(true);
      }
    }
  }

  Future<void> _onPlayUserAudio(PlayUserAudioRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      if (currentState.userAudioPath != null) {
        await _referenceAudioPlayer.stop();
        await _flutterTts.stop();

        await _userAudioPlayer.play(DeviceFileSource(currentState.userAudioPath!));
        emit(currentState.copyWith(isUserAudioPlaying: true));
      }
    }
  }

  Future<void> _onStopUserAudio(StopUserAudioRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      await _userAudioPlayer.stop();
      emit(currentState.copyWith(isUserAudioPlaying: false));
    }
  }

  Future<void> _onPlayInstruction(PlayInstructionRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      await _referenceAudioPlayer.stop();
      await _userAudioPlayer.stop();

      emit(currentState.copyWith(isInstructionSpeaking: true));
      try {
        await _flutterTts.speak(event.textToSpeak);
        await _flutterTts.awaitSpeakCompletion(true);
      } finally {
        if (this.state is ExerciseReadyState) {
          emit((this.state as ExerciseReadyState).copyWith(isInstructionSpeaking: false));
        }
      }
    }
  }

  Future<void> _onStopAudioPlayback(StopAudioPlayback event, Emitter<ExerciseState> emit) async {
    await _referenceAudioPlayer.stop();
    await _userAudioPlayer.stop();
    await _flutterTts.stop();
  }

  @override
  Future<void> close() {
    _audioRecorder.dispose();
    _referenceAudioPlayer.dispose();
    _userAudioPlayer.dispose();
    _flutterTts.stop();
    return super.close();
  }
}