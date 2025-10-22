import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String lastname;
  final String username;

  const UserModel({
    required this.id,
    required this.name,
    required this.lastname,
    required this.username,
  });

  String get fullName => '$name $lastname';

  @override
  List<Object> get props => [id, name, lastname, username];
}

class UserStats extends Equatable {
  final int dayStreak;
  final int totalXp;
  final String currentLeague;
  final int top3Finishes;

  const UserStats({
    required this.dayStreak,
    required this.totalXp,
    required this.currentLeague,
    required this.top3Finishes,
  });

  @override
  List<Object> get props => [dayStreak, totalXp, currentLeague, top3Finishes];
}