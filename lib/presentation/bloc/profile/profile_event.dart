part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

// --- CORRECCIÓN CLAVE ---
// Se elimina el parámetro 'userId' porque ya no es necesario.
class FetchProfileData extends ProfileEvent {}