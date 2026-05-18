import 'package:flutter/material.dart';
import 'editar_perfil_page.dart';
import 'home_page.dart';
import 'agenda_page.dart';
import 'viagens_page.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;

  const NavBar({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const EditarPerfilPage();
        break;
      case 1:
        page = const HomePage();
        break;
      case 2:
        page = const AgendaPage();
        break;
      case 3:
        page = const ViagensPage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),

      type: BottomNavigationBarType.fixed,

      selectedItemColor: const Color(0xFF23D2B5),
      unselectedItemColor: const Color(0xFFB0B9C6), // Match the light grayish-blue from the image

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
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
