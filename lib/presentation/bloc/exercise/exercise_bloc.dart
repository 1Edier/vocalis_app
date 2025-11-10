import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../data/models/audio_validation_result.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/repositories/audio_validation_repository.dart';

part 'exercise_event.dart';
part 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  // Herramientas de audio
  final _audioRecorder = AudioRecorder();
  final _referenceAudioPlayer = AudioPlayer();
  final _userAudioPlayer = AudioPlayer();
  final _flutterTts = FlutterTts();

  // Repositorios
  final _audioValidationRepository = AudioValidationRepository();

  ExerciseBloc() : super(ExerciseInitial()) {
    _initializeTts();

    _userAudioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        if (this.state is ExerciseReadyState && (this.state as ExerciseReadyState).isUserAudioPlaying) {
          add(StopUserAudioRequested());
        }
      }
    });

    on<InitializeExercise>((event, emit) => emit(ExerciseReady(event.exercise)));
    on<PlayAudioRequested>(_onPlayAudio);
    on<StartRecordingRequested>(_onStartRecording);
    on<StopRecordingRequested>(_onStopRecording);
    on<ValidateRecordingRequested>(_onValidateRecording);
    on<PlayUserAudioRequested>(_onPlayUserAudio);
    on<StopUserAudioRequested>(_onStopUserAudio);
    on<PlayInstructionRequested>(_onPlayInstruction);
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  /// Maneja la reproducción del audio de referencia del ejercicio.
  Future<void> _onPlayAudio(PlayAudioRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      // Primero, nos aseguramos de que no haya otras reproducciones activas
      await _flutterTts.stop();
      await _userAudioPlayer.stop();

      emit(AudioPlaying(currentState.exercise, userAudioPath: currentState.userAudioPath));
      try {
        await _referenceAudioPlayer.play(UrlSource(currentState.exercise.referenceAudioUrl));
        await _referenceAudioPlayer.onPlayerComplete.first;
      } finally {
        // --- AQUÍ ESTÁ LA CORRECCIÓN CLAVE ---
        // Al finalizar, emitimos explícitamente el estado 'ExerciseReady'.
        // Esto asegura que la UI vuelva a mostrar el botón de Play.
        if (state is AudioPlaying) {
          final currentPlayingState = state as AudioPlaying;
          emit(ExerciseReady(
            currentPlayingState.exercise,
            userAudioPath: currentPlayingState.userAudioPath,
            isUserAudioPlaying: currentPlayingState.isUserAudioPlaying,
            isInstructionSpeaking: false, // Aseguramos que este flag se reinicie
          ));
        }
      }
    }
  }

  /// Inicia la grabación de audio desde el micrófono.
  Future<void> _onStartRecording(StartRecordingRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      try {
        if (await _audioRecorder.hasPermission()) {
          final tempDir = await getTemporaryDirectory();
          final path = '${tempDir.path}/user_recording.m4a';
          await _audioRecorder.start(const RecordConfig(), path: path);
          emit(RecordingInProgress(currentState.exercise));
        }
      } catch (e) {
        emit(ValidationFailure(currentState.exercise, userAudioPath: null, error: "Error al iniciar grabación."));
      }
    }
  }

  /// Detiene la grabación y dispara el evento de validación.
  Future<void> _onStopRecording(StopRecordingRequested event, Emitter<ExerciseState> emit) async {
    if (state is RecordingInProgress) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        add(ValidateRecordingRequested(path));
      }
    }
  }

  /// Envía el audio grabado al servicio de validación.
  Future<void> _onValidateRecording(ValidateRecordingRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      emit(ValidatingAudio(currentState.exercise, userAudioPath: event.filePath));
      try {
        final result = await _audioValidationRepository.validateAudio(event.filePath);
        emit(ValidationSuccess(currentState.exercise, userAudioPath: event.filePath, result: result));
      } catch (e) {
        emit(ValidationFailure(currentState.exercise, userAudioPath: event.filePath, error: e.toString()));
      }
    }
  }

  /// Reproduce el audio grabado por el usuario.
  Future<void> _onPlayUserAudio(PlayUserAudioRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      if (currentState.userAudioPath != null) {
        await _userAudioPlayer.play(DeviceFileSource(currentState.userAudioPath!));
        emit(currentState.copyWith(isUserAudioPlaying: true));
      }
    }
  }

  /// Detiene la reproducción del audio del usuario.
  Future<void> _onStopUserAudio(StopUserAudioRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      await _userAudioPlayer.stop();
      emit(currentState.copyWith(isUserAudioPlaying: false));
    }
  }

  /// Lee en voz alta el texto de la instrucción.
  Future<void> _onPlayInstruction(PlayInstructionRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      // Detenemos otras reproducciones para evitar solapamientos
      await _referenceAudioPlayer.stop();
      await _userAudioPlayer.stop();

      emit(currentState.copyWith(isInstructionSpeaking: true));
      try {
        await _flutterTts.speak(event.textToSpeak);
        // Esperamos a que el TTS termine
        await _flutterTts.awaitSpeakCompletion(true);
      } finally {
        if (this.state is ExerciseReadyState) {
          emit((this.state as ExerciseReadyState).copyWith(isInstructionSpeaking: false));
        }
      }
    }
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