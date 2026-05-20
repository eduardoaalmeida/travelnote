import 'package:flutter/material.dart';
import 'alterar_dados_page.dart';
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
    Color iconColor = const Color(0xFF1F3A6A),
    Color titleColor = Colors.black,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          titulo,
          style: TextStyle(fontWeight: FontWeight.w600, color: titleColor),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Meu Perfil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7FB),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDDE3EE), width: 2),
              ),
              child: const CircleAvatar(
                radius: 58,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/images/perfil.png'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _nome,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'eduardo@gmail.com',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            _itemPerfil(
              icon: Icons.shield_outlined,
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
            const SizedBox(height: 12),
            _itemPerfil(
              icon: Icons.logout,
              titulo: 'Sair',
              iconColor: Colors.red,
              titleColor: Colors.red,
              onTap: _confirmarSaida,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 0),
    );
  }
}
