import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String role;
  final String fullName;
  final int age;
  final String? avatarUrl;
  final String? difficultyLevel;

  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    required this.age,
    this.avatarUrl,
    this.difficultyLevel,
  });

  // --- ESTA ES LA SECCIÓN CORREGIDA ---
  // Hacemos el parsing más seguro para evitar errores con valores nulos.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Usamos el operador '??' para dar un valor por defecto si el campo es nulo.
      id: json['id'] ?? '', // CORRECCIÓN: Si id es nulo, usa un string vacío.
      email: json['email'] ?? '', // CORRECCIÓN: Si email es nulo, usa un string vacío.
      role: json['role'] ?? 'user', // CORRECCIÓN: Si role es nulo, asume 'user'.
      fullName: json['fullName'] ?? 'Usuario sin nombre', // CORRECCIÓN: Si fullName es nulo, usa un texto por defecto.
      age: json['age'] ?? 0, // CORRECCIÓN: Si age es nulo, usa 0.

      // Estos campos ya eran "nulables" (String?), por lo que no necesitan cambios.
      avatarUrl: json['avatarUrl'],
      difficultyLevel: json['difficultyLevel'],
    );
  }

  @override
  List<Object?> get props => [id, email, role, fullName, age, avatarUrl, difficultyLevel];
}