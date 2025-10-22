import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart'; // <-- CORREGIDO A RUTA RELATIVA
import '../../../data/repositories/auth_repository.dart'; // <-- CORREGIDO A RUTA RELATIVA

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  void _onLoginRequested(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(event.username, event.password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(const AuthFailure('Usuario o contraseña incorrectos'));
    }
  }
}