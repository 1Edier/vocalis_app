import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../bloc/progression/progression_bloc.dart';
import '../../widgets/widgets.dart';
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
    context.read<ProgressionBloc>().add(FetchProgressionMap());
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: null,
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
              return const Center(
                child: Text(
                  "No se encontraron categorías.",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

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
                // Header "Mapa de Progreso"
                GlassHeader(
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      height: 60,
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
                // Tabs de categorías
                GlassHeader(
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.secondary,
                    unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    indicatorColor: Theme.of(context).colorScheme.secondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: categories.map((cat) => Tab(text: cat.name)).toList(),
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
          return const Center(
            child: Text("Cargando...", style: TextStyle(color: Colors.white)),
          );
        },
      ),
    );
  }
}
