import '../models/lesson_model.dart';

// La responsabilidad de este repositorio es manejar las categorías principales de lecciones.
// Los ejercicios específicos de cada categoría ahora son manejados por ExerciseRepository.

class LessonRepository {

  // Obtiene la lista de categorías principales para mostrar en la pantalla de inicio.
  // En el futuro, esto podría venir de un endpoint de la API como /api/v1/categories.
  // Por ahora, mantenemos estos datos de forma local ("mockeada") ya que son relativamente estáticos.
  Future<List<LessonCategory>> getLessonCategories() async {
    // Simulamos una pequeña demora de red.
    await Future.delayed(const Duration(milliseconds: 300));

    // Devolvemos las tres categorías principales que se muestran en tu diseño.
    return const [
      LessonCategory(id: 'fonema', title: 'Fonema', completed: 18, total: 40),
      LessonCategory(id: 'ritmo', title: 'Ritmo', completed: 35, total: 40),
      LessonCategory(id: 'entonacion', title: 'Entonación', completed: 3, total: 40),
    ];
  }

// El método getLessonsForCategory ha sido eliminado de este repositorio
// porque esa lógica ahora la maneja el ExerciseRepository al obtener
// ejercicios filtrados por categoría.
}