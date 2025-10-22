import 'package:flutter/material.dart';
import 'package:vocalis/data/models/user_model.dart';
import 'package:vocalis/presentation/screens/home/home_screen.dart';
import 'package:vocalis/presentation/screens/profile/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  final UserModel user;
  const MainScaffold({super.key, required this.user});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const HomeScreen(),
      const Center(child: Text('Página de Metas')),
      const Center(child: Text('Página de Comunidad')),
      ProfileScreen(user: widget.user), // CORREGIDO
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.flag_outlined), label: 'Metas'),
              BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Comunidad'),
              BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xff9d8cf5),
            unselectedItemColor: Colors.grey[400],
            onTap: _onItemTapped,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.white,
            iconSize: 28,
          ),
        ),
      ),
    );
  }
}