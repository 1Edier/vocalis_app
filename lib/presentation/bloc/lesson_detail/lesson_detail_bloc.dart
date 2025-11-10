import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/exercise_model.dart'; // <<< CAMBIO: Usamos el nuevo modelo
import '../../../data/repositories/exercise_repository.dart'; // <<< CAMBIO: Usamos el nuevo repositorio

part 'lesson_detail_event.dart';
part 'lesson_detail_state.dart';

class LessonDetailBloc extends Bloc<LessonDetailEvent, LessonDetailState> {
  final ExerciseRepository _exerciseRepository;

  LessonDetailBloc({required ExerciseRepository exerciseRepository})
      : _exerciseRepository = exerciseRepository,
        super(LessonDetailInitial()) {
    on<FetchExercisesForLevel>(_onFetchExercises);
  }

  Future<void> _onFetchExercises(
      FetchExercisesForLevel event,
      Emitter<LessonDetailState> emit,
      ) async {
    emit(LessonDetailLoading());
    try {
      final exercises = await _exerciseRepository.getExercises(
        category: event.category,
        difficultyLevel: event.level,
      );
      emit(LessonDetailLoadSuccess(exercises));
    } catch (e) {
      emit(LessonDetailLoadFailure(e.toString()));
    }
  }
}