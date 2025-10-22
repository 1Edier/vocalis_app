import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/repositories/lesson_repository.dart'; // <-- CORREGIDO A RUTA RELATIVA

part 'lesson_detail_event.dart';
part 'lesson_detail_state.dart';

class LessonDetailBloc extends Bloc<LessonDetailEvent, LessonDetailState> {
  final LessonRepository _lessonRepository;

  LessonDetailBloc({required LessonRepository lessonRepository})
      : _lessonRepository = lessonRepository,
        super(LessonDetailInitial()) {
    on<FetchLessonsForCategory>(_onFetchLessons);
  }

  Future<void> _onFetchLessons(
      FetchLessonsForCategory event,
      Emitter<LessonDetailState> emit,
      ) async {
    emit(LessonDetailLoading());
    try {
      final lessons = await _lessonRepository.getLessonsForCategory(event.categoryId);
      emit(LessonDetailLoadSuccess(lessons));
    } catch (_) {
      emit(const LessonDetailLoadFailure('No se pudieron cargar las lecciones.'));
    }
  }
}