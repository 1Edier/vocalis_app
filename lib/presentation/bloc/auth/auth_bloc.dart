import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/progression_repository.dart'; // <<< AÑADIDO

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final ProgressionRepository _progressionRepository; // <<< AÑADIDO

  AuthBloc({
    required AuthRepository authRepository,
    required ProgressionRepository progressionRepository, // <<< AÑADIDO
  })  : _authRepository = authRepository,
        _progressionRepository = progressionRepository, // <<< AÑADIDO
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final user = await _authRepository.tryAutoLogin();
    if (user != null) {
      emit(AuthSuccess(user));
    } else {
      emit(const AuthFailure("No hay sesión activa."));
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email: event.email, password: event.password);
      // Opcional: Podrías llamar a initializeProgress aquí también como un respaldo
      // _progressionRepository.initializeProgress();
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // 1. Intentamos registrar al usuario
      await _authRepository.signUp(
        fullName: event.fullName,
        age: event.age,
        email: event.email,
        password: event.password,
      );

      // 2. Si el registro fue exitoso, iniciamos sesión automáticamente para obtener el token
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      // 3. Con el token ya guardado, llamamos para inicializar el progreso
      await _progressionRepository.initializeProgress();

      // 4. Finalmente, emitimos el estado de éxito con los datos del usuario
      emit(AuthSuccess(user));

    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(const AuthFailure("Sesión cerrada."));
  }
}