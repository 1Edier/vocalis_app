import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocalis/data/repositories/progression_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/user_stats_summary.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        progressionRepository: RepositoryProvider.of<ProgressionRepository>(context),
      )..add(FetchProfileData()),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          title: const Text('Perfil', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              tooltip: 'Cerrar Sesión',
              icon: const Icon(Icons.logout, color: Colors.black54),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Cerrar Sesión'),
                    content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                      TextButton(
                        child: const Text('Aceptar'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<ProfileBloc>().add(FetchProfileData());
          },
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildProfileHeader(context, user),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text('Tu Progreso General', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoading && state is! ProfileLoadSuccess) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ProfileLoadSuccess) {
                    return _buildStatsSection(context, state.stats);
                  }
                  if (state is ProfileLoadFailure) {
                    return Center(
                      child: Text(
                        "No se pudieron cargar tus estadísticas.\n${state.error}",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
          backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null || user.avatarUrl!.isEmpty
              ? Text(
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
            style: TextStyle(fontSize: 32, color: AppTheme.primaryColor),
          )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                user.email,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 26),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, UserStatsSummary stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(value: stats.completedCount.toString(), label: 'Completados'),
                _StatItem(value: stats.totalStars.toString(), label: 'Estrellas'),
                _StatItem(value: '${stats.completionPercentage.toStringAsFixed(0)}%', label: 'Progreso'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Desglose por Categoría', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20)),
        const SizedBox(height: 16),
        ...stats.byCategory.entries.map((entry) {
          final categoryName = entry.key.isNotEmpty ? entry.key[0].toUpperCase() + entry.key.substring(1) : '';
          return _CategoryStatItem(
            categoryName: categoryName,
            stat: entry.value,
          );
        }).toList(),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
      ],
    );
  }
}

class _CategoryStatItem extends StatelessWidget {
  final String categoryName;
  final CategoryStat stat;
  const _CategoryStatItem({required this.categoryName, required this.stat});

  @override
  Widget build(BuildContext context) {
    final double percentage = (stat.total > 0) ? stat.completed / stat.total : 0.0;
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(categoryName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${stat.completed} / ${stat.total}', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              color: AppTheme.primaryColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber[700], size: 20),
                const SizedBox(width: 4),
                Text('${stat.stars} estrellas obtenidas', style: TextStyle(color: Colors.grey[700])),
              ],
            )
          ],
        ),
      ),
    );
  }
}