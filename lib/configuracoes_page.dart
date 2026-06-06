import 'package:flutter/material.dart';
import 'theme_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navbar.dart';
import 'perfil_page.dart';
import 'politica_privacidade_page.dart';
import 'login_page.dart';
import 'notificacoes_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  bool _carregando = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  Future<void> _carregarPreferencias() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _carregando = false);
      return;
    }
    try {
      final doc = await _db.collection('usuarios').doc(user.uid).get();
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        final prefs = data['preferencias'] as Map<String, dynamic>?;
        if (prefs != null) {
          final noturno = (prefs['modoNoturno'] as bool?) ?? false;
          // Só sincroniza se for true (restaura dark mode salvo)
          // Nunca chama setModoNoturno(false) ao abrir a tela para não resetar o tema
          if (noturno) ThemeNotifier.instance.setModoNoturno(true);
          setState(() {
            _idioma = (prefs['idioma'] as String?) ?? 'Português';
            _pais = (prefs['pais'] as String?) ?? 'Brasil';
            _moeda = (prefs['moeda'] as String?) ?? 'BRL';
            _notificacoesAtivas = (prefs['notificacoes'] as bool?) ?? true;
            _modoNoturno = noturno;
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _carregando = false);
  }

  Future<void> _salvarPreferencias() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _db.collection('usuarios').doc(user.uid).update({
        'preferencias': {
          'idioma': _idioma,
          'pais': _pais,
          'moeda': _moeda,
          'notificacoes': _notificacoesAtivas,
          'modoNoturno': _modoNoturno,
        },
        'usuario_logado': user.email ?? '',
        'atualizado_em': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Widget _buildItem({
    required String title,
    String? value,
    IconData? trailingIcon,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subtitleColor = isDark ? Colors.white54 : const Color(0xFF94A3B8);

        return Container(
          color: bgColor,
          child: ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 4,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value != null && value.isNotEmpty) ...[
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: subtitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                if (trailingIcon != null)
                  Icon(trailingIcon, color: subtitleColor, size: 24),
                if (showArrow)
                  Icon(Icons.chevron_right, color: subtitleColor, size: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroup(List<Widget> items) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final borderColor = isDark
            ? const Color(0xFF334155)
            : const Color(0xFFEFF2F6);
        final dividerColor = isDark
            ? const Color(0xFF334155)
            : const Color(0xFFF1F5F9);

        List<Widget> children = [];
        for (int i = 0; i < items.length; i++) {
          children.add(items[i]);
          if (i < items.length - 1) {
            children.add(Divider(height: 1, thickness: 1, color: dividerColor));
          }
        }
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              top: BorderSide(color: borderColor, width: 1),
              bottom: BorderSide(color: borderColor, width: 1),
            ),
          ),
          child: Column(children: children),
        );
      },
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
            return RadioListTile<T>(
              value: opcao,
              groupValue: selecionado,
              title: Text(opcao.toString()),
              onChanged: (value) => Navigator.of(context).pop(value),
              activeColor: const Color(0xFF1B4E88),
              selected: opcao == selecionado,
            );
          }).toList(),
        ),
      ),
    );
    if (resultado != null) {
      onChanged(resultado);
      await _salvarPreferencias();
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Configurações',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                        trailingIcon: _notificacoesAtivas
                            ? Icons.notifications_none
                            : Icons.notifications_off_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificacoesPage(),
                            ),
                          );
                        },
                      ),
                      Builder(
                        builder: (context) {
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;
                          final bgColor = isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white;
                          final titleColor = isDark
                              ? Colors.white
                              : const Color(0xFF0F172A);
                          return Container(
                            color: bgColor,
                            child: SwitchListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 4,
                              ),
                              title: Text(
                                'Modo Noturno',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                ),
                              ),
                              secondary: Icon(
                                _modoNoturno
                                    ? Icons.dark_mode
                                    : Icons.light_mode_outlined,
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF94A3B8),
                              ),
                              value: _modoNoturno,
                              activeColor: const Color(0xFF10B981),
                              onChanged: (val) async {
                                setState(() => _modoNoturno = val);
                                ThemeNotifier.instance.setModoNoturno(val);
                                await _salvarPreferencias();
                              },
                            ),
                          );
                        },
                      ),
                    ]),
                    const SizedBox(height: 32),
                    _buildGroup([
                      _buildItem(
                        title: 'Sair da Conta',
                        trailingIcon: Icons.logout,
                        onTap: () {
                          final nav = Navigator.of(context);
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text('Sair do sistema'),
                              content: const Text(
                                'Tem certeza que deseja sair?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Não'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(dialogContext);
                                    try {
                                      await GoogleSignIn().signOut();
                                    } catch (_) {}
                                    await FirebaseAuth.instance.signOut();
                                    nav.pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Sim'),
                                ),
                              ],
                            ),
                          );
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
                      _buildItem(title: 'Versão', value: '1.0'),
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
