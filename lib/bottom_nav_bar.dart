import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,

      type: BottomNavigationBarType.fixed,

      selectedItemColor: const Color(0xFF1F3A6A),
      unselectedItemColor: Colors.grey,

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),

        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Agenda',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.flight_outlined),
          label: 'Viagens',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
      ],
    );
  }
}
