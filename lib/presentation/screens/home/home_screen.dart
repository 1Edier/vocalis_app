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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              // --- LÓGICA DE NIVELES ACTUALIZADA ---
              // Usamos List.generate para crear las 5 tarjetas de nivel dinámicamente.
              children: List.generate(5, (index) {
                // El nivel que se muestra en la tarjeta (siempre de 1 a 5).
                final displayLevel = index + 1;

                // Determina si esta categoría necesita un ajuste de nivel.
                final bool isAdvancedCategory = category.title == 'Ritmo' || category.title == 'Entonación';

                // El nivel real que se enviará a la API.
                // Si es "Ritmo" o "Entonación", se le suma 1 (Lvl 1 -> API 2, Lvl 2 -> API 3, etc.).
                // Si es "Fonemas", se queda igual (Lvl 1 -> API 1).
                final apiLevel = isAdvancedCategory ? displayLevel + 1 : displayLevel;

                // Lógica simple para bloquear niveles (puedes hacerla más compleja después).
                final bool isLocked = displayLevel > 1;

                return Padding(
                  // Añade espacio a la derecha de cada tarjeta, excepto la última.
                  padding: EdgeInsets.only(right: index == 4 ? 0 : 16.0),
                  child: _LessonCard(
                    level: displayLevel,
                    // Solo muestra la barra de progreso en la primera tarjeta desbloqueada.
                    progress: !isLocked ? (category.completed / category.total) : 0.0,
                    isLocked: isLocked,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => LessonDetailScreen(
                          category: category,
                          level: apiLevel, // <<< Se pasa el nivel correcto a la API
                        ),
                      ));
                    },
                  ),
                );
              }),
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
        width: 140,
        height: 160,
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