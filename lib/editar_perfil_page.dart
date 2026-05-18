import 'package:flutter/material.dart';

import 'alterar_dados_page.dart';
import 'configuracoes_page.dart';
import 'politica_privacidade_page.dart';
import 'login_page.dart';
import 'viagens_page.dart';

import 'navbar.dart';

class EditarPerfilPage extends StatelessWidget {
  const EditarPerfilPage({super.key});

  Widget _buildItem({
    required BuildContext context,
    required IconData icon,
    required String texto,
    required Widget? destino,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (destino != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => destino));
        } else if (isLogout) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3F8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: isLogout ? const Color(0xFFE53935) : const Color(0xFF1A5276),
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isLogout ? const Color(0xFFE53935) : const Color(0xFF101828),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF101828)),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Meu Perfil',
          style: TextStyle(
            color: Color(0xFF101828),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE0E5EC),
                  width: 3,
                ),
              ),
              child: const CircleAvatar(
                radius: 55,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Eduardo Andrade',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'eduardo@gmail.com',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A5276),
              ),
            ),
            const SizedBox(height: 30),
            _buildItem(
              context: context,
              icon: Icons.person_outline,
              texto: 'Dados Pessoais',
              destino: const AlterarDadosPage(),
            ),
            _buildItem(
              context: context,
              icon: Icons.map_outlined,
              texto: 'Minhas Viagens',
              destino: const ViagensPage(),
            ),
            _buildItem(
              context: context,
              icon: Icons.settings_outlined,
              texto: 'Configurações',
              destino: const ConfiguracoesPage(),
            ),
            _buildItem(
              context: context,
              icon: Icons.verified_user_outlined,
              texto: 'Termos de Privacidade',
              destino: const PoliticaPrivacidadePage(),
            ),
            _buildItem(
              context: context,
              icon: Icons.logout,
              texto: 'Sair',
              destino: null,
              isLogout: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 0),
    );
  }
}
