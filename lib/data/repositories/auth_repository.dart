import 'package:vocalis/data/models/user_model.dart';

class AuthRepository {
  Future<UserModel> login(String username, String password) async {
    // Simulamos una llamada de red
    await Future.delayed(const Duration(seconds: 1));
    if (username.toLowerCase() == 'flutterdev' && password == '123456') {
      return const UserModel(
        id: 'user_01',
        name: 'Nombre',
        lastname: 'Apellido',
        username: 'flutterdev',
      );
    } else {
      throw Exception('Credenciales incorrectas');
    }
  }
}