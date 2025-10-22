// lib/data/models/lesson_model.dart

import 'package:equatable/equatable.dart';

// Modelo para las categorías principales (Fonemas, Ritmo, etc.)
class LessonCategory extends Equatable {
  final String id;
  final String title;
  final int completed;
  final int total;

  const LessonCategory({
    required this.id,
    required this.title,
    required this.completed,
    required this.total,
  });

  @override
  List<Object> get props => [id, title, completed, total];
}

// Modelo para una lección individual (Rr, Pl, etc.)
class Lesson extends Equatable {
  final String id;
  final String title;
  final String iconName; // <-- CORREGIDO a iconName
  final bool isLocked;
  final int badgeCount; // <-- CORREGIDO, se había borrado

  const Lesson({
    required this.id,
    required this.title,
    required this.iconName,
    this.isLocked = false,
    this.badgeCount = 0,
  });

  @override
  List<Object> get props => [id, title, isLocked, badgeCount, iconName];
}