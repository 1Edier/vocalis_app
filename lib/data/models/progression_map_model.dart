import 'package:equatable/equatable.dart';

// --- Modelo para un Ejercicio individual en el mapa de progreso ---
class ExerciseProgress extends Equatable {
  final String id;
  final String exerciseId;
  final int orderIndex;
  final String title;
  final String category;
  final String subcategory;
  final int difficultyLevel;
  final String textContent;
  final String status;
  final int stars; // <<< AÑADIDO: Las estrellas ganadas en este ejercicio

  const ExerciseProgress({
    required this.id,
    required this.exerciseId,
    required this.orderIndex,
    required this.title,
    required this.category,
    required this.subcategory,
    required this.difficultyLevel,
    required this.textContent,
    required this.status,
    required this.stars, // <<< AÑADIDO
  });

  factory ExerciseProgress.fromJson(Map<String, dynamic> json) {
    return ExerciseProgress(
      id: json['id'] ?? '',
      exerciseId: json['exercise_id'] ?? '',
      orderIndex: json['order_index'] ?? 0,
      title: json['title'] ?? 'Sin Título',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      difficultyLevel: json['difficulty_level'] ?? 1,
      textContent: json['text_content'] ?? '',
      status: json['status'] ?? 'locked',
      stars: json['stars'] ?? 0, // <<< AÑADIDO
    );
  }

  @override
  List<Object?> get props => [id, exerciseId, orderIndex, title, status, stars]; // <<< AÑADIDO
}

// --- El resto del archivo no cambia ---

class CategoryProgress extends Equatable {
  final String name;
  final String category;
  final int total;
  final int completed;
  final List<ExerciseProgress> exercises;

  const CategoryProgress({
    required this.name,
    required this.category,
    required this.total,
    required this.completed,
    required this.exercises,
  });

  factory CategoryProgress.fromJson(Map<String, dynamic> json) {
    var exercisesList = (json['exercises'] as List)
        .map((i) => ExerciseProgress.fromJson(i))
        .toList();

    return CategoryProgress(
      name: json['name'] ?? 'Categoría',
      category: json['category'] ?? '',
      total: json['total'] ?? 0,
      completed: json['completed'] ?? 0,
      exercises: exercisesList,
    );
  }

  @override
  List<Object?> get props => [name, category, total, completed, exercises];
}

class ProgressionMap extends Equatable {
  final int totalExercises;
  final int completedExercises;
  final int currentExerciseIndex;
  final List<CategoryProgress> categories;

  const ProgressionMap({
    required this.totalExercises,
    required this.completedExercises,
    required this.currentExerciseIndex,
    required this.categories,
  });

  factory ProgressionMap.fromJson(Map<String, dynamic> json) {
    var categoriesList = (json['categories'] as List)
        .map((i) => CategoryProgress.fromJson(i))
        .toList();

    return ProgressionMap(
      totalExercises: json['total_exercises'] ?? 0,
      completedExercises: json['completed_exercises'] ?? 0,
      currentExerciseIndex: json['current_exercise_index'] ?? 1,
      categories: categoriesList,
    );
  }

  @override
  List<Object?> get props => [totalExercises, completedExercises, categories];
}