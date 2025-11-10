import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart'; // <<< CAMBIO: Usamos AuthRepository

part 'profile_event.dart';
part 'profile_state.dart';

// El ProfileBloc ahora podría usarse para actualizar el perfil,
// pero para solo mostrar datos, no es estrictamente necesario.
// Lo mantenemos por si se añade la funcionalidad de "Editar Perfil".
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository; // <<< CAMBIO: Usamos AuthRepository

  ProfileBloc({required AuthRepository authRepository}) // <<< CAMBIO
      : _authRepository = authRepository,
        super(ProfileInitial()) {
    on<FetchProfileData>((event, emit) async {
      emit(ProfileLoading());
      try {
        // Obtenemos los datos más recientes del perfil
        final user = await _authRepository.getProfile();
        emit(ProfileLoadSuccess(user: user));
      } catch (e) {
        emit(ProfileLoadFailure(e.toString()));
      }
    });
  }
}