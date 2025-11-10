import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../../bloc/home/home_bloc.dart';
import '../lesson_detail/lesson_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Aún usamos LessonRepository para obtener las categorías principales
    // Este repositorio podría ser renombrado a "CategoryRepository" en el futuro
    // para mayor claridad.
    return BlocProvider(
      create: (context) => HomeBloc(
        lessonRepository: RepositoryProvider.of<LessonRepository>(context),
      )..add(FetchHomeData()),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: const _HomeAppBar(),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HomeLoadSuccess) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  return _LessonCategorySection(category: state.categories[index]);
                },
              );
            }
            if (state is HomeLoadFailure) {
              return Center(child: Text(state.error));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatChip(Icons.local_fire_department_rounded, '3', Colors.orange),
            _buildStatChip(Icons.shield_outlined, '1432 XP', Colors.blue),
            _buildStatChip(Icons.favorite, '∞', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _LessonCategorySection extends StatelessWidget {
  final LessonCategory category;
  const _LessonCategorySection({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(category.title, style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              Icon(Icons.workspace_premium_rounded, color: Colors.orange[600], size: 20),
              const SizedBox(width: 4),
              Text(
                '${category.completed}/${category.total}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Por ahora, asumimos que siempre hay 5 niveles, algunos bloqueados
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _LessonCard(
                  level: 1,
                  progress: category.completed / category.total, // El progreso podría ser más granular por nivel
                  onTap: () {
                    // --- NAVEGACIÓN ACTUALIZADA ---
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => LessonDetailScreen(category: category, level: 1)));
                  },
                ),
                const SizedBox(width: 16),
                const _LessonCard(level: 2, isLocked: true),
                const SizedBox(width: 16),
                const _LessonCard(level: 3, isLocked: true),
                const SizedBox(width: 16),
                const _LessonCard(level: 4, isLocked: true),
                const SizedBox(width: 16),
                const _LessonCard(level: 5, isLocked: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final int level;
  final double progress;
  final bool isLocked;
  final VoidCallback? onTap;

  const _LessonCard({required this.level, this.progress = 0.0, this.isLocked = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLocked ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 140, // Ancho fijo para las tarjetas
        height: 160, // Alto fijo para las tarjetas
        decoration: BoxDecoration(
          color: isLocked ? const Color(0xFFE0E0E0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: isLocked
            ? const Center(child: Icon(Icons.lock, size: 48, color: Color(0xFFBDBDBD)))
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lvl $level',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontSize: 20)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.workspace_premium_rounded, color: Colors.orange[600]),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    color: Colors.orange[600],
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}