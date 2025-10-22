part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

class FetchProfileData extends ProfileEvent {
  final String userId;
  const FetchProfileData(this.userId);
}