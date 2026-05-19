import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'home_page.dart';
import 'agenda_page.dart';
import 'viagens_page.dart';
import 'perfil_page.dart';
import 'politica_privacidade_page.dart';
import 'login_page.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  Widget item(
    String titulo,
    String valor, {
    IconData? trailingIcon,
    Color trailingIconColor = const Color(0xFF9AA6B2),
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(titulo),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (valor.isNotEmpty) ...[
                  Text(valor, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(width: 5),
                ],
                if (trailingIcon != null) ...[
                  Icon(trailingIcon, size: 18, color: trailingIconColor),
                  const SizedBox(width: 5),
                ],
                if (showArrow) const Icon(Icons.arrow_forward_ios, size: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _idioma = 'Português';
  String _pais = 'Brasil';
  String _moeda = 'BRL';
  bool _notificacoesAtivas = true;
  bool _modoNoturno = false;

  void _onNavTap(BuildContext context, int index) {
    if (index == 3) return;

    Widget destination;
    switch (index) {
      case 0:
        destination = const HomePage();
        break;
      case 1:
        destination = const AgendaPage();
        break;
      case 2:
        destination = const ViagensPage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
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
              activeColor: const Color(0xFF1F3A6A),
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
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Configurações',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  item(
                    'Idioma',
                    _idioma,
                    onTap: () => _selecionarOpcao<String>(
                      context,
                      'Idioma',
                      ['Português', 'Inglês'],
                      _idioma,
                      (value) => setState(() => _idioma = value),
                    ),
                  ),
                  item(
                    'País',
                    _pais,
                    onTap: () => _selecionarOpcao<String>(
                      context,
                      'País',
                      ['Brasil', 'Portugal', 'Estados Unidos'],
                      _pais,
                      (value) => setState(() => _pais = value),
                    ),
                  ),
                  item(
                    'Moeda',
                    _moeda,
                    onTap: () => _selecionarOpcao<String>(
                      context,
                      'Moeda',
                      ['BRL', 'USD', 'EUR'],
                      _moeda,
                      (value) => setState(() => _moeda = value),
                    ),
                  ),
                  item(
                    'Gerenciar minha conta',
                    '',
                    trailingIcon: Icons.person_outline,
                    trailingIconColor: const Color(0xFF9AA6B2),
                    showArrow: false,
                    onTap: () => _abrirPerfil(context),
                  ),
                  item(
                    'Notificações',
                    '',
                    trailingIcon: Icons.notifications_none,
                    trailingIconColor: const Color(0xFF9AA6B2),
                    showArrow: false,
                    onTap: () => setState(
                      () => _notificacoesAtivas = !_notificacoesAtivas,
                    ),
                  ),
                  item(
                    'Modo Noturno',
                    '',
                    trailingIcon: Icons.light_mode_outlined,
                    trailingIconColor: const Color(0xFF9AA6B2),
                    showArrow: false,
                    onTap: () => setState(() => _modoNoturno = !_modoNoturno),
                  ),
                  const Spacer(),
                  item(
                    'Sair da Conta',
                    '',
                    trailingIcon: Icons.exit_to_app,
                    trailingIconColor: const Color(0xFF9AA6B2),
                    showArrow: false,
                    onTap: () => _abrirLogin(context),
                  ),
                  item(
                    'Termos e Condições',
                    '',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PoliticaPrivacidadePage(),
                      ),
                    ),
                  ),
                  item('Versão', '1.0'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }
}
