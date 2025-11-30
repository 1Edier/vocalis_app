import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/progression_map_model.dart';
import '../../../data/repositories/progression_repository.dart';

part 'progression_event.dart';
part 'progression_state.dart';

class ProgressionBloc extends Bloc<ProgressionEvent, ProgressionState> {
  final ProgressionRepository _progressionRepository;

  ProgressionBloc({required ProgressionRepository progressionRepository})
      : _progressionRepository = progressionRepository,
        super(ProgressionInitial()) {
    on<FetchProgressionMap>(_onFetchProgressionMap);
  }

  Future<void> _onFetchProgressionMap(
      FetchProgressionMap event,
      Emitter<ProgressionState> emit,
      ) async {
    emit(ProgressionLoading());
    try {
      final map = await _progressionRepository.getProgressionMap();
      emit(ProgressionLoadSuccess(map));
    } catch (e) {
      emit(ProgressionLoadFailure(e.toString()));
    }
  }
}