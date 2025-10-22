import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/lesson_model.dart'; // <-- CORREGIDO A RUTA RELATIVA
import '../../../data/repositories/lesson_repository.dart'; // <-- CORREGIDO A RUTA RELATIVA

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final LessonRepository _lessonRepository;
  HomeBloc({required LessonRepository lessonRepository})
      : _lessonRepository = lessonRepository,
        super(HomeInitial()) {
    on<FetchHomeData>((event, emit) async {
      emit(HomeLoading());
      try {
        final categories = await _lessonRepository.getLessonCategories();
        emit(HomeLoadSuccess(categories));
      } catch (_) {
        emit(const HomeLoadFailure("Error al cargar las lecciones"));
      }
    });
  }
}