import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocalis/presentation/bloc/progression/progression_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/progression_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final ProgressionRepository _progressionRepository;
  final ProgressionBloc _progressionBloc;

  AuthBloc({
    required AuthRepository authRepository,
    required ProgressionRepository progressionRepository,
    required ProgressionBloc progressionBloc,
  })  : _authRepository = authRepository,
        _progressionRepository = progressionRepository,
        _progressionBloc = progressionBloc,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<TokenExpired>(_onTokenExpired);
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
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(
        fullName: event.fullName,
        age: event.age,
        email: event.email,
        password: event.password,
      );

      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      // 1. Inicializa el progreso del nuevo usuario
      await _progressionRepository.initializeProgress();
      // 2. Dispara el evento para que ProgressionBloc recargue los datos
      _progressionBloc.add(FetchProgressionMap());

      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(const AuthFailure("Sesión cerrada."));
  }

  Future<void> _onTokenExpired(TokenExpired event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(const AuthFailure("Tu sesión ha expirado. Por favor, inicia sesión nuevamente."));
  }
}