import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/models/audio_validation_result.dart'; // Importar nuevo modelo
import '../../../data/repositories/audio_validation_repository.dart'; // Importar nuevo repo

part 'exercise_event.dart';
part 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  // Grabadora y reproductores de audio
  final _audioRecorder = AudioRecorder();
  final _referenceAudioPlayer = AudioPlayer(); // Para el audio de ejemplo
  final _userAudioPlayer = AudioPlayer(); // Para el audio del usuario
  final _audioValidationRepository = AudioValidationRepository();

  ExerciseBloc() : super(ExerciseInitial()) {
    // Escuchamos los cambios de estado del reproductor de usuario para actualizar la UI
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
    on<PlayUserAudioRequested>(_onPlayUserAudio);
    on<ValidateRecordingRequested>(_onValidateRecording);
    on<StopUserAudioRequested>(_onStopUserAudio);
  }

  Future<void> _onPlayAudio(PlayAudioRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      emit(AudioPlaying(currentState.exercise));
      try {
        await _referenceAudioPlayer.play(UrlSource(currentState.exercise.referenceAudioUrl));
        // Espera a que termine la reproducción
        await _referenceAudioPlayer.onPlayerComplete.first;
      } finally {
        // Vuelve al estado listo, manteniendo la info del audio grabado si existe
        emit(ExerciseReady(currentState.exercise, userAudioPath: currentState.userAudioPath));
      }
    }
  }

  Future<void> _onStartRecording(StartRecordingRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      try {
        if (await _audioRecorder.hasPermission()) {
          final tempDir = await getTemporaryDirectory();
          final path = '${tempDir.path}/myFile.m4a';

          await _audioRecorder.start(const RecordConfig(), path: path);
          emit(RecordingInProgress(currentState.exercise));
        }
        // Aquí podrías emitir un estado de "permiso denegado"
      } catch (e) {
        // Manejar error de grabación
      }
    }
  }

  Future<void> _onStopRecording(StopRecordingRequested event, Emitter<ExerciseState> emit) async {
    if (state is RecordingInProgress) {
      final currentState = state as RecordingInProgress;
      final path = await _audioRecorder.stop();
      if (path != null) {
        // En lugar de emitir RecordingComplete, ahora disparamos la validación
        add(ValidateRecordingRequested(path));
      }
    }
  }
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

  Future<void> _onPlayUserAudio(PlayUserAudioRequested event, Emitter<ExerciseState> emit) async {
    if (state is ExerciseReadyState) {
      final currentState = state as ExerciseReadyState;
      if (currentState.userAudioPath != null) {
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

  @override
  Future<void> close() {
    _audioRecorder.dispose();
    _referenceAudioPlayer.dispose();
    _userAudioPlayer.dispose();
    return super.close();
  }
}