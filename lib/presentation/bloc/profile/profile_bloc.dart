import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart'; // <-- CORREGIDO A RUTA RELATIVA
import '../../../data/repositories/user_repository.dart'; // <-- CORREGIDO A RUTA RELATIVA

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;

  ProfileBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(ProfileInitial()) {
    on<FetchProfileData>(_onFetchProfile);
  }

  Future<void> _onFetchProfile(
      FetchProfileData event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());
    try {
      // CORREGIDO: Future.wait ahora es más seguro con los tipos
      final List<dynamic> results = await Future.wait([
        _userRepository.getUserProfile(event.userId),
        _userRepository.getUserStats(event.userId),
      ]);
      final user = results[0] as UserModel;
      final stats = results[1] as UserStats;
      emit(ProfileLoadSuccess(user: user, stats: stats));
    } catch (_) {
      emit(const ProfileLoadFailure('No se pudo cargar el perfil.'));
    }
  }
}