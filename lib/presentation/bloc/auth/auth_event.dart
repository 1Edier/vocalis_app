part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email; // <-- De username a email
  final String password;
  const LoginRequested({required this.email, required this.password});
}

class SignUpRequested extends AuthEvent {
  final String fullName; // <-- Nuevo
  final int age; // <-- Nuevo
  final String email;
  final String password;

  const SignUpRequested({
    required this.fullName,
    required this.age,
    required this.email,
    required this.password,
  });
}

// --- NUEVO EVENTO ---
class AppStarted extends AuthEvent {}
class LogoutRequested extends AuthEvent {}