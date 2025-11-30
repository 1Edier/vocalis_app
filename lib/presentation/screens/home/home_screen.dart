import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/progression_repository.dart';
import '../../bloc/progression/progression_bloc.dart';
import 'locked_category_screen.dart';
import 'progression_path_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProgressionBloc(
        progressionRepository: RepositoryProvider.of<ProgressionRepository>(context),
      )..add(FetchProgressionMap()),
      child: Scaffold(
        backgroundColor: Colors.transparent, // <-- Hacemos el Scaffold transparente
        appBar: const _HomeAppBar(),
        body: BlocBuilder<ProgressionBloc, ProgressionState>(
          builder: (context, state) {
            if (state is ProgressionLoading) {
              return Center(child: Lottie.asset('assets/lottie/cat_loader.json', width: 200, height: 200, repeat: true));
            }
            if (state is ProgressionLoadSuccess) {
              final categories = state.progressionMap.categories;
              if (categories.isEmpty) {
                return const Center(child: Text("No se encontraron categorías de progreso.", style: TextStyle(color: Colors.white)));
              }
              return DefaultTabController(
                length: categories.length,
                child: Column(
                  children: [
                    Container(
                      color: AppTheme.backgroundColor.withOpacity(0.9), // Fondo semitransparente
                      child: TabBar(
                        labelColor: AppTheme.primaryColor,
                        unselectedLabelColor: Colors.grey[600],
                        indicatorColor: AppTheme.primaryColor,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                        tabs: categories.map((cat) => Tab(text: cat.name)).toList(),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: List.generate(categories.length, (index) {
                          final currentCategory = categories[index];
                          bool isCategoryLocked = false;
                          String previousCategoryName = '';
                          if (index > 0) {
                            final previousCategory = categories[index - 1];
                            previousCategoryName = previousCategory.name;
                            if (previousCategory.completed < previousCategory.total) {
                              isCategoryLocked = true;
                            }
                          }
                          if (isCategoryLocked) {
                            return LockedCategoryScreen(categoryName: currentCategory.name, previousCategoryName: previousCategoryName);
                          } else {
                            return ProgressionPathScreen(categoryProgress: currentCategory);
                          }
                        }),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (state is ProgressionLoadFailure) {
              return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text("Error al cargar tu progreso: ${state.error}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white))));
            }
            return const Center(child: Text("Cargando tu progreso...", style: TextStyle(color: Colors.white)));
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
        color: AppTheme.backgroundColor.withOpacity(0.9), // Fondo semitransparente
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