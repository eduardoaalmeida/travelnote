import 'package:flutter/material.dart';
import 'login_page.dart';
import 'configuracoes_page.dart';
import 'alterar_dados_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String _nome = 'Professor';

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
  }) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF23D2B5)),

        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        trailing: const Icon(Icons.arrow_forward_ios, size: 18),

        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFF23D2B5),

              child: Icon(Icons.person, size: 60, color: Colors.white),
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

                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar nome',
                  onPressed: _abrirEdicaoNome,
                ),
              ],
            ),

            const SizedBox(height: 5),

            const Text(
              'usuario@email.com',

              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 35),

            _itemPerfil(
              icon: Icons.edit_outlined,
              titulo: 'Alterar Dados',

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlterarDadosPage()),
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
              icon: Icons.home_outlined,
              titulo: 'Voltar para Home',

              onTap: () {
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                onPressed: _confirmarSaida,

                icon: const Icon(Icons.logout),

                label: const Text('Sair do sistema'),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
