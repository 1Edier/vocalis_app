part of 'progression_bloc.dart';

abstract class ProgressionEvent extends Equatable {
  const ProgressionEvent();
  @override
  List<Object> get props => [];
}

class FetchProgressionMap extends ProgressionEvent {}