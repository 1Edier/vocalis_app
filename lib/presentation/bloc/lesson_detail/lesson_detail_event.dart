part of 'lesson_detail_bloc.dart';

abstract class LessonDetailEvent extends Equatable {
  const LessonDetailEvent();
  @override
  List<Object> get props => [];
}

class FetchLessonsForCategory extends LessonDetailEvent {
  final String categoryId;
  const FetchLessonsForCategory(this.categoryId);
}