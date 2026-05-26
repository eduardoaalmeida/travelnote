import 'package:flutter/material.dart';
import 'alterar_dados_page.dart';
import 'home_page.dart';
import 'navbar.dart';
import 'configuracoes_page.dart';
import 'login_page.dart';
import 'politica_privacidade_page.dart';
import 'viagens_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String _nome = 'Eduardo Andrade';

  final TextEditingController _nomeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _abrirEdicaoNome() {
    _nomeController.text = _nome;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Text(
              'Editar nome',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _nomeController,
              autofocus: true,

              decoration: const InputDecoration(
                labelText: 'Novo nome',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                if (_nomeController.text.isNotEmpty) {
                  setState(() {
                    _nome = _nomeController.text;
                  });
                }

                Navigator.pop(context);
              },

              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarSaida() {
    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        title: const Text('Sair do sistema'),

        content: const Text('Tem certeza que deseja sair?'),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text('Não'),
          ),

          ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            ),

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),

            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  Widget _itemPerfil({
    required IconData icon,
    required String titulo,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF1B4E88),
    Color titleColor = const Color(0xFF0F172A),
    Color? leadingBgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: leadingBgColor ?? iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          titulo,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
          size: 24,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A), size: 24),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          ),
        ),
        title: const Text(
          'Meu Perfil',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCBD5E1), width: 2.5),
              ),
              child: const CircleAvatar(
                radius: 56,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/images/perfil.png'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _nome,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'eduardo@gmail.com',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1B4E88),
              ),
            ),
            const SizedBox(height: 32),
            _itemPerfil(
              icon: Icons.person_outline,
              titulo: 'Dados Pessoais',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlterarDadosPage()),
                );
              },
            ),
            _itemPerfil(
              icon: Icons.map_outlined,
              titulo: 'Minhas Viagens',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViagensPage()),
                );
              },
            ),
            _itemPerfil(
              icon: Icons.settings_outlined,
              titulo: 'Configurações',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConfiguracoesPage()),
                );
              },
            ),
            _itemPerfil(
              icon: Icons.verified_user_outlined,
              titulo: 'Termos de Privacidade',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PoliticaPrivacidadePage(),
                  ),
                );
              },
            ),
            _itemPerfil(
              icon: Icons.logout,
              titulo: 'Sair',
              iconColor: const Color(0xFFEF4444),
              titleColor: const Color(0xFFEF4444),
              leadingBgColor: const Color(0xFFFEE2E2),
              onTap: _confirmarSaida,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 0),
    );
  }
}
