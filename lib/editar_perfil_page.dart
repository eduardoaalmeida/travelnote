import 'package:flutter/material.dart';

import 'alterar_dados_page.dart';
import 'configuracoes_page.dart';

import '../bottom_nav_bar.dart';

class EditarPerfilPage extends StatelessWidget {
  const EditarPerfilPage({super.key});

  Widget item(
    BuildContext context,
    IconData icon,
    String texto,
    Widget? destino,
  ) {
    return GestureDetector(
      onTap: () {
        if (destino != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => destino));
        }
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 15),

        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),

          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10),
          ],
        ),

        child: Row(
          children: [
            Icon(icon, color: Colors.blueGrey),

            const SizedBox(width: 15),

            Expanded(
              child: Text(
                texto,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,

        title: const Text('Meu Perfil', style: TextStyle(color: Colors.black)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,

              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
            ),

            const SizedBox(height: 15),

            const Text(
              'Eduardo Andrade',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const Text(
              'eduardo@gmail.com',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            item(
              context,
              Icons.person_outline,
              'Alterar Dados',
              const AlterarDadosPage(),
            ),

            item(
              context,
              Icons.settings_outlined,
              'Configurações',
              const ConfiguracoesPage(),
            ),

            item(context, Icons.logout, 'Sair', null),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavBar(currentIndex: 3, onTap: (_) {}),
    );
  }
}
