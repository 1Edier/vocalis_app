import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/repositories/lesson_repository.dart';

part 'exercise_event.dart';
part 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final LessonRepository _lessonRepository;

  ExerciseBloc({required LessonRepository lessonRepository})
      : _lessonRepository = lessonRepository,
        super(ExerciseInitial()) {
    on<FetchExercise>(_onFetchExercise);
    on<StartRecordingRequested>(_onStartRecording);
    on<StopRecordingRequested>(_onStopRecording);
    // Simulación de reproducción de audio
    on<PlayAudioRequested>((event, emit) async {
      if (state is ExerciseReadyState) {
        final currentExercise = (state as ExerciseReadyState).exercise;
        emit(AudioPlaying(currentExercise));
        // Simulamos que el audio dura 2 segundos
        await Future.delayed(const Duration(seconds: 2));
        emit(ExerciseReady(currentExercise));
      }
    });
  }

  Future<void> _onFetchExercise(FetchExercise event, Emitter<ExerciseState> emit) async {
    emit(ExerciseLoading());
    try {
      final exercise = await _lessonRepository.getExerciseForLesson(event.lessonId);
      emit(ExerciseReady(exercise));
    } catch (_) {
      emit(ExerciseLoadFailure());
    }
  }

  void _onStartRecording(StartRecordingRequested event, Emitter<ExerciseState> emit) {
    if (state is ExerciseReadyState) {
      emit(RecordingInProgress((state as ExerciseReadyState).exercise));
    }
  }

  void _onStopRecording(StopRecordingRequested event, Emitter<ExerciseState> emit) {
    if (state is RecordingInProgress) {
      emit(RecordingComplete((state as RecordingInProgress).exercise));
    }
  }
}