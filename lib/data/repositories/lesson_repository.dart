// lib/data/repositories/lesson_repository.dart

import 'package:vocalis/data/models/lesson_model.dart';
import 'package:vocalis/data/models/exercise_model.dart';

class LessonRepository {
  Future<List<LessonCategory>> getLessonCategories() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const [
      // CORREGIDO: Se eliminó el parámetro 'lessons' que no era necesario aquí
      LessonCategory(id: 'cat_fonemas', title: 'Fonemas', completed: 18, total: 40),
      LessonCategory(id: 'cat_ritmo', title: 'Ritmo', completed: 35, total: 40),
      LessonCategory(id: 'cat_entonacion', title: 'Entonación', completed: 3, total: 40),
    ];
  }

  Future<List<Lesson>> getLessonsForCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // En una app real, esto dependería del categoryId
    return const [
      // CORREGIDO: Usamos 'iconName' consistentemente
      Lesson(id: 'f1', title: 'Rr', iconName: 'pencil', badgeCount: 1),
      Lesson(id: 'f2', title: 'Pl', iconName: 'book', badgeCount: 1),
      Lesson(id: 'f3', title: 'Dl', iconName: 'bike', badgeCount: 1),
      Lesson(id: 'f4', title: 'Br', iconName: '', isLocked: true),
      Lesson(id: 'f5', title: 'Cr', iconName: '', isLocked: true),
      Lesson(id: 'f6', title: 'Fr', iconName: '', isLocked: true),
    ];
  }

  Future<ExerciseModel> getExerciseForLesson(String lessonId) async {
    // Simulamos una llamada de red para obtener los detalles del ejercicio
    await Future.delayed(const Duration(milliseconds: 600));

    // Devolvemos datos mockeados. En una app real, esto vendría de una API.
    return const ExerciseModel(
      id: 'ex_rr_01',
      phoneme: 'Rr',
      word: 'Carro',
      audioUrl: 'https://example.com/audio/carro.mp3', // URL de audio de ejemplo
      avatarUrl: 'https://i.pravatar.cc/150?img=12', // URL de avatar de ejemplo
    );
  }
}