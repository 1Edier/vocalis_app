import 'package:equatable/equatable.dart';

// Representa las estadísticas para una categoría individual (fonema, ritmo, etc.)
class CategoryStat extends Equatable {
  final int total;
  final int completed;
  final int stars;

  const CategoryStat({
    required this.total,
    required this.completed,
    required this.stars,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      total: json['total'] ?? 0,
      completed: json['completed'] ?? 0,
      stars: json['stars'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [total, completed, stars];
}

// Representa el resumen completo de las estadísticas del usuario
class UserStatsSummary extends Equatable {
  final int completedCount;
  final int totalStars;
  final double completionPercentage;
  final Map<String, CategoryStat> byCategory;

  const UserStatsSummary({
    required this.completedCount,
    required this.totalStars,
    required this.completionPercentage,
    required this.byCategory,
  });

  factory UserStatsSummary.fromJson(Map<String, dynamic> json) {
    // Parseo seguro del mapa de categorías
    final Map<String, CategoryStat> categories = {};
    if (json['by_category'] is Map) {
      (json['by_category'] as Map).forEach((key, value) {
        if (value is Map<String, dynamic>) {
          categories[key] = CategoryStat.fromJson(value);
        }
      });
    }

    return UserStatsSummary(
      completedCount: json['completed_count'] ?? 0,
      totalStars: json['total_stars'] ?? 0,
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
      byCategory: categories,
    );
  }

  @override
  List<Object?> get props => [completedCount, totalStars, completionPercentage, byCategory];
}