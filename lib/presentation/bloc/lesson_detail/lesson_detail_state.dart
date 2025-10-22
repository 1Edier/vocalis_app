part of 'lesson_detail_bloc.dart';

abstract class LessonDetailState extends Equatable {
  const LessonDetailState();
  @override
  List<Object> get props => [];
}

class LessonDetailInitial extends LessonDetailState {}
class LessonDetailLoading extends LessonDetailState {}
class LessonDetailLoadSuccess extends LessonDetailState {
  final List<Lesson> lessons;
  const LessonDetailLoadSuccess(this.lessons);
}
class LessonDetailLoadFailure extends LessonDetailState {
  final String error;
  const LessonDetailLoadFailure(this.error);
}