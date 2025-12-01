import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocalis/data/repositories/progression_repository.dart';
import 'package:intl/intl.dart';
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
        extendBodyBehindAppBar: true, // Extiende el body detrás del AppBar
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AppBar(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0b1016).withOpacity(0.7) // Oscuro semitransparente
                    : Colors.white.withOpacity(0.8), // Blanco semitransparente
                elevation: 0,
                title: Text(
                  'Perfil',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Cerrar Sesión',
                    icon: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2ce0bd).withOpacity(0.1) // Borde neón sutil
                            : Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<ProfileBloc>().add(FetchProfileData());
          },
          child: ListView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            children: [
              _buildProfileHeader(context, user),
              const SizedBox(height: 16),
              _buildUserInfoCard(context, user),
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
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: ClipOval(
            child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                ? Image.network(
                    user.avatarUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        print('Image loaded successfully');
                        return child;
                      }
                      print('Loading image...');
                      return Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(BuildContext context, UserModel user) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final memberSince = user.createdAt != null 
        ? dateFormat.format(user.createdAt!) 
        : 'No disponible';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Personal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              icon: Icons.cake_outlined,
              label: 'Edad',
              value: '${user.age} años',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              icon: Icons.calendar_today_outlined,
              label: 'Miembro desde',
              value: memberSince,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? tooltip,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              tooltip != null
                  ? Tooltip(
                      message: tooltip,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      color: isDark 
          ? const Color(0xFF1a2332) // bg-screen-center en dark
          : const Color(0xFFF8FAFB), // Gris muy claro en light
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${stat.completed} / ${stat.total}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: isDark
                  ? const Color(0xFF2B3A4A) // Más oscuro en dark
                  : const Color(0xFFE0E7ED), // Gris claro en light
              color: Theme.of(context).colorScheme.secondary, // Turquesa neón
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: const Color(0xFFFFB020), // Amarillo dorado consistente
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${stat.stars} estrellas obtenidas',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}