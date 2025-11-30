part of 'progression_bloc.dart';

abstract class ProgressionState extends Equatable {
  const ProgressionState();
  @override
  List<Object> get props => [];
}

class ProgressionInitial extends ProgressionState {}
class ProgressionLoading extends ProgressionState {}
class ProgressionLoadSuccess extends ProgressionState {
  final ProgressionMap progressionMap;
  const ProgressionLoadSuccess(this.progressionMap);
}
class ProgressionLoadFailure extends ProgressionState {
  final String error;
  const ProgressionLoadFailure(this.error);
}