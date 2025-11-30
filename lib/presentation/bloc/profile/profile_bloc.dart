import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_stats_summary.dart';
import '../../../data/repositories/progression_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  // Ahora solo depende de ProgressionRepository para obtener las estadísticas
  final ProgressionRepository _progressionRepository;

  ProfileBloc({required ProgressionRepository progressionRepository})
      : _progressionRepository = progressionRepository,
        super(ProfileInitial()) {
    on<FetchProfileData>(_onFetchProfileStats);
  }

  Future<void> _onFetchProfileStats(
      FetchProfileData event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());
    try {
      final stats = await _progressionRepository.getStatsSummary();
      emit(ProfileLoadSuccess(stats: stats));
    } catch (e) {
      emit(ProfileLoadFailure(e.toString()));
    }
  }
}