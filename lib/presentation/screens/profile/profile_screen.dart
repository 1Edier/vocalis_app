import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocalis/data/models/user_model.dart';
import 'package:vocalis/data/repositories/user_repository.dart';
import 'package:vocalis/presentation/bloc/profile/profile_bloc.dart';
import 'package:vocalis/presentation/widgets/stat_card.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        userRepository: RepositoryProvider.of<UserRepository>(context),
      )..add(FetchProfileData(user.id)),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(title: const Text('Perfil')),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileLoadSuccess) {
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildProfileHeader(context, state.user),
                  const SizedBox(height: 24),
                  _buildStatsSection(context, state.stats),
                ],
              );
            }
            if (state is ProfileLoadFailure) {
              return Center(child: Text(state.error));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    user.username,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.verified_user, color: Colors.green[400], size: 18),
                ],
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 40,
          backgroundColor: Color(0xffc50000),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, UserStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            StatCard(
              icon: Icons.local_fire_department_rounded,
              value: stats.dayStreak.toString(),
              label: 'Day Streak',
              iconColor: Colors.orange,
            ),
            StatCard(
              icon: Icons.flash_on_rounded,
              value: stats.totalXp.toString(),
              label: 'Total XP',
              iconColor: Colors.amber,
            ),
            StatCard(
              icon: Icons.shield_rounded,
              value: stats.currentLeague,
              label: 'Current League',
              iconColor: const Color(0xffcd7f32), // Bronze color
            ),
            StatCard(
              icon: Icons.military_tech_rounded,
              value: stats.top3Finishes.toString(),
              label: 'Top 3 Finishes',
              iconColor: Colors.blueAccent,
            ),
          ],
        ),
      ],
    );
  }
}