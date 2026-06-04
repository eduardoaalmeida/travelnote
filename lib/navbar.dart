import 'package:flutter/material.dart';
import 'perfil_page.dart';
import 'home_page.dart';
import 'agenda_page.dart';
import 'viagens_page.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;

  const NavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const PerfilPage();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),

      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).cardColor,
      selectedItemColor: isDark
          ? const Color(0xFF38BDF8)
          : const Color(0xFF1B4E88),
      unselectedItemColor: isDark
          ? const Color(0xFF6B7280)
          : const Color(0xFF94A3B8),
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),

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
