import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Navbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF4FA7E1), // Azul do design
      unselectedItemColor: Colors.grey[400],
      currentIndex: currentIndex,
      onTap: onTap,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Perfil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: 'Agenda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          label: 'Viagens',
        ),
      ],
    );
  }
}
