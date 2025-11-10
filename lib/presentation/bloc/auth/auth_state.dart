part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

// Estado para la SplashScreen mientras se decide a dónde ir
class AuthInitial extends AuthState {}

// Estado mientras se realiza una llamada a la API (login o signup)
class AuthLoading extends AuthState {}

// Estado cuando el usuario está autenticado y tenemos sus datos
class AuthSuccess extends AuthState {
  final UserModel user;
  const AuthSuccess(this.user);
}

// Estado para cualquier fallo de autenticación o cuando no hay sesión
class AuthFailure extends AuthState {
  final String error;
  const AuthFailure(this.error);
}

// Estado específico para cuando el registro es exitoso pero se requiere login
class AuthSignUpSuccess extends AuthState {}