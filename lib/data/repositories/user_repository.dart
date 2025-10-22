import 'package:vocalis/data/models/user_model.dart';

class UserRepository {
  Future<UserModel> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const UserModel(
      id: 'user_01',
      name: 'Nombre',
      lastname: 'Apellido',
      username: 'flutterdev',
    );
  }

  Future<UserStats> getUserStats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const UserStats(
      dayStreak: 3,
      totalXp: 1432,
      currentLeague: 'Bronze',
      top3Finishes: 0,
    );
  }
}