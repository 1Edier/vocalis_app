import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/repositories/lesson_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final LessonRepository _lessonRepository;

  HomeBloc({required LessonRepository lessonRepository})
      : _lessonRepository = lessonRepository,
        super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
  }

  Future<void> _onFetchHomeData(
      FetchHomeData event,
      Emitter<HomeState> emit,
      ) async {
    emit(HomeLoading());
    try {
      // Llama al repositorio real para obtener las categorías
      final categories = await _lessonRepository.getLessonCategories();
      emit(HomeLoadSuccess(categories));
    } catch (e) {
      emit(HomeLoadFailure(e.toString()));
    }
  }
}