import 'package:flutter/material.dart';
import 'navbar.dart';
import 'perfil_page.dart';
import 'politica_privacidade_page.dart';
import 'login_page.dart';
import 'firebase_helper.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  String _idioma = 'Português';
  String _pais = 'Brasil';
  String _moeda = 'BRL';
  bool _notificacoesAtivas = true;
  bool _modoNoturno = false;

  Widget _buildItem({
    required String title,
    String? value,
    IconData? trailingIcon,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null && value.isNotEmpty) ...[
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
            ],
            if (trailingIcon != null)
              Icon(
                trailingIcon,
                color: const Color(0xFF94A3B8),
                size: 24,
              ),
            if (showArrow)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF94A3B8),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(List<Widget> items) {
    List<Widget> children = [];
    for (int i = 0; i < items.length; i++) {
      children.add(items[i]);
      if (i < items.length - 1) {
        children.add(
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
          ),
        );
      }
    }
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEFF2F6), width: 1),
          bottom: BorderSide(color: Color(0xFFEFF2F6), width: 1),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Future<void> _selecionarOpcao<T>(
    BuildContext context,
    String titulo,
    List<T> opcoes,
    T selecionado,
    ValueChanged<T> onChanged,
  ) async {
    final T? resultado = await showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: opcoes.map((opcao) {
            final bool isSelected = opcao == selecionado;
            return RadioListTile<T>(
              value: opcao,
              groupValue: selecionado,
              title: Text(opcao.toString()),
              onChanged: (value) {
                Navigator.of(context).pop(value);
              },
              activeColor: const Color(0xFF1B4E88),
              selected: isSelected,
            );
          }).toList(),
        ),
      ),
    );

    if (resultado != null) {
      onChanged(resultado);
    }
  }

  void _abrirLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _abrirPerfil(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PerfilPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A), size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Configurações',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildGroup([
                _buildItem(
                  title: 'Idioma',
                  value: _idioma,
                  showArrow: true,
                  onTap: () => _selecionarOpcao<String>(
                    context,
                    'Idioma',
                    ['Português', 'Inglês'],
                    _idioma,
                    (value) => setState(() => _idioma = value),
                  ),
                ),
                _buildItem(
                  title: 'País',
                  value: _pais,
                  showArrow: true,
                  onTap: () => _selecionarOpcao<String>(
                    context,
                    'País',
                    ['Brasil', 'Portugal', 'Estados Unidos'],
                    _pais,
                    (value) => setState(() => _pais = value),
                  ),
                ),
                _buildItem(
                  title: 'Moeda',
                  value: _moeda,
                  showArrow: true,
                  onTap: () => _selecionarOpcao<String>(
                    context,
                    'Moeda',
                    ['BRL', 'USD', 'EUR'],
                    _moeda,
                    (value) => setState(() => _moeda = value),
                  ),
                ),
                _buildItem(
                  title: 'Gerenciar Minha conta',
                  trailingIcon: Icons.person_outline,
                  onTap: () => _abrirPerfil(context),
                ),
                _buildItem(
                  title: 'Notificações',
                  trailingIcon: _notificacoesAtivas ? Icons.notifications_none : Icons.notifications_off_outlined,
                  onTap: () => setState(
                    () => _notificacoesAtivas = !_notificacoesAtivas,
                  ),
                ),
                _buildItem(
                  title: 'Modo Noturno',
                  trailingIcon: Icons.lightbulb_outline,
                  onTap: () => setState(() => _modoNoturno = !_modoNoturno),
                ),
              ]),
              const SizedBox(height: 32),
              _buildGroup([
                _buildItem(
                  title: 'Sair da Conta',
                  trailingIcon: Icons.logout,
                  onTap: () async {
                    await FirebaseHelper.logout();
                    if (mounted) {
                      _abrirLogin(context);
                    }
                  },
                ),
                _buildItem(
                  title: 'Termos e Condições',
                  showArrow: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PoliticaPrivacidadePage(),
                    ),
                  ),
                ),
                _buildItem(
                  title: 'Versão',
                  value: '1.0',
                ),
              ]),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 0),
    );
  }
}
