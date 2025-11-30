import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:vocalis/core/theme/app_theme.dart';
import '../../data/models/user_model.dart';
import '../bloc/auth/auth_bloc.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  final UserModel user;
  const MainScaffold({super.key, required this.user});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  // Controladores y composición para la animación de Lottie
  late final AnimationController _lottieController;
  Future<LottieComposition>? _composition;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const HomeScreen(),
      // Hacemos las pantallas placeholder transparentes
      Scaffold(backgroundColor: Colors.transparent, body: Center(child: Text('Página de Metas', style: TextStyle(color: Colors.white)))),
      Scaffold(backgroundColor: Colors.transparent, body: Center(child: Text('Página de Comunidad', style: TextStyle(color: Colors.white)))),
      ProfileScreen(user: widget.user),
    ];

    // Lógica para la animación de fondo suave
    _lottieController = AnimationController(vsync: this);
    _composition = AssetLottie('assets/lottie/space_background.json').load();
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _lottieController.reset();
        _lottieController.forward();
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
        }
      },
      child: Stack(
        children: [
          // --- FONDO DE ANIMACIÓN GLOBAL ---
          Positioned.fill(
            child: FutureBuilder<LottieComposition>(
              future: _composition,
              builder: (context, snapshot) {
                var composition = snapshot.data;
                if (composition != null) {
                  _lottieController.duration = composition.duration;
                  if (!_lottieController.isAnimating) {
                    _lottieController.forward();
                  }
                  return Lottie(composition: composition, controller: _lottieController, fit: BoxFit.cover);
                } else {
                  return Container(color: const Color(0xFF2E2A4F));
                }
              },
            ),
          ),
          // --- SCAFFOLD TRANSPARENTE ---
          Scaffold(
            backgroundColor: Colors.transparent, // <-- El Scaffold principal es transparente
            body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
            bottomNavigationBar: Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 2, blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.flag_rounded), label: 'Metas'),
                    BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Comunidad'),
                    BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Ajustes'),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: AppTheme.primaryColor,
                  unselectedItemColor: Colors.grey[400],
                  onTap: _onItemTapped,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  iconSize: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}