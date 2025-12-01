import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../bloc/progression/progression_bloc.dart';
import 'locked_category_screen.dart';
import 'progression_path_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Le pedimos al ProgressionBloc que cargue (o recargue) los datos
    // cada vez que esta pantalla se construye.
    context.read<ProgressionBloc>().add(FetchProgressionMap());
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: null, // Sin AppBar predefinido
      body: BlocBuilder<ProgressionBloc, ProgressionState>(
        builder: (context, state) {
          if (state is ProgressionLoading) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/cat_loader.json',
                width: 200,
                height: 200,
                repeat: true,
              ),
            );
          }
          if (state is ProgressionLoadSuccess) {
            final categories = state.progressionMap.categories;

            if (categories.isEmpty) {
              return const Center(child: Text("No se encontraron categorías.", style: TextStyle(color: Colors.white)));
            }

            // Gestionamos nuestro propio TabController para mantener la pestaña seleccionada
            if (_tabController == null || _tabController!.length != categories.length) {
              _tabController?.dispose();
              _tabController = TabController(
                length: categories.length,
                vsync: this,
                initialIndex: _currentTabIndex.clamp(0, categories.length - 1),
              );
              _tabController!.addListener(() {
                if (!_tabController!.indexIsChanging) {
                  setState(() {
                    _currentTabIndex = _tabController!.index;
                  });
                }
              });
            }

            return Column(
              children: [
                // Header "Mapa de Progreso" con glassmorphism
                ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0b1016).withOpacity(0.7)
                            : Colors.white.withOpacity(0.8),
                        border: Border(
                          bottom: BorderSide(
                            color: isDark
                                ? const Color(0xFF2ce0bd).withOpacity(0.1)
                                : Colors.grey.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.center,
                          child: Text(
                            'Mapa de Progreso',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Tabs de categorías con glassmorphism
                ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0b1016).withOpacity(0.7)
                            : Colors.white.withOpacity(0.8),
                        border: Border(
                          bottom: BorderSide(
                            color: isDark
                                ? const Color(0xFF2ce0bd).withOpacity(0.1)
                                : Colors.grey.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Theme.of(context).colorScheme.secondary,
                        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        indicatorColor: Theme.of(context).colorScheme.secondary,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                        tabs: categories.map((cat) => Tab(text: cat.name)).toList(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
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
                        return LockedCategoryScreen(
                          categoryName: currentCategory.name,
                          previousCategoryName: previousCategoryName,
                        );
                      } else {
                        return ProgressionPathScreen(categoryProgress: currentCategory);
                      }
                    }),
                  ),
                ),
              ],
            );
          }
          if (state is ProgressionLoadFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Error al cargar tu progreso: ${state.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
          return const Center(child: Text("Cargando...", style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }
}