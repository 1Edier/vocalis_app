part of '../home/home_bloc.dart'; // Asegúrate que el path es correcto

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoadSuccess extends HomeState {
  final List<LessonCategory> categories;
  const HomeLoadSuccess(this.categories);
}
class HomeLoadFailure extends HomeState {
  final String error;
  const HomeLoadFailure(this.error);
}