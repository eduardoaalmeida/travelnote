import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'alterar_senha_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AlterarDadosPage extends StatefulWidget {
  const AlterarDadosPage({super.key});

  @override
  State<AlterarDadosPage> createState() => _AlterarDadosPageState();
}

class _AlterarDadosPageState extends State<AlterarDadosPage> {
  late final TextEditingController _cpfController;
  late final TextEditingController _telefoneController;

  late final MaskTextInputFormatter _cpfFormatter;
  late final MaskTextInputFormatter _telefoneFormatter;

  bool _carregando = true;
  bool _salvando = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _nome = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {'#': RegExp(r'[0-9]')},
    );
    _cpfController = TextEditingController();

    _telefoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {'#': RegExp(r'[0-9]')},
    );
    _telefoneController = TextEditingController();

    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _db.collection('usuarios').doc(user.uid).get();
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        final cpf = (data['cpf'] as String?) ?? '';
        final tel = (data['telefone'] as String?) ?? '';

        setState(() {
          _nome = (data['nome'] as String?) ?? user.displayName ?? '';
          _email = (data['email'] as String?) ?? user.email ?? '';
          _carregando = false;
        });

        // Aplica formatação via formatter
        _cpfFormatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: cpf.replaceAll(RegExp(r'[^0-9]'), '')),
        );
        _cpfController.text = _cpfFormatter.getMaskedText();

        _telefoneFormatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: tel.replaceAll(RegExp(r'[^0-9]'), '')),
        );
        _telefoneController.text = _telefoneFormatter.getMaskedText();
      } else if (mounted) {
        setState(() {
          _nome = user.displayName ?? '';
          _email = user.email ?? '';
          _carregando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _salvarDados() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cpf = _cpfController.text.trim();
    final telefone = _telefoneController.text.trim();

    if (cpf.isEmpty || telefone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos antes de salvar.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      await _db.collection('usuarios').doc(user.uid).update({
        'cpf': cpf,
        'telefone': telefone,
        'usuario_logado': user.email ?? '',
        'atualizado_em': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados salvos com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  void _signOut() {
    final nav = Navigator.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair do sistema'),
        content: const Text('Tem certeza que deseja sair?'),
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
                MaterialPageRoute(builder: (_) => const LoginPage()),
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
  }

  InputDecoration _decoration(String hint, IconData prefixIcon) {
    return InputDecoration(
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 22),
      suffixIcon: const Icon(
        Icons.edit_outlined,
        color: Color(0xFF94A3B8),
        size: 20,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF1B4E88)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Image.asset(
          'assets/images/logo_completa.png',
          height: 50,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Alterar dados',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFCBD5E1),
                                        width: 2.5,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 56,
                                      backgroundColor: Theme.of(
                                        context,
                                      ).cardColor,
                                      backgroundImage: AssetImage(
                                        'assets/images/perfil.png',
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    bottom: 4,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.12,
                                            ),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _nome.isNotEmpty ? _nome : 'Usuário',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _email,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1B4E88),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'CPF',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _cpfController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [_cpfFormatter],
                                decoration: _decoration(
                                  '001.001.001-01',
                                  Icons.lock_outline,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'TELEFONE',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _telefoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [_telefoneFormatter],
                                decoration: _decoration(
                                  '(79) 99999-9999',
                                  Icons.phone_outlined,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Botão Salvar Dados
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B4E88),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: _salvando ? null : _salvarDados,
                                    child: Center(
                                      child: _salvando
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Salvar Dados',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2DD4BF),
                                      Color(0xFF10B981),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2DD4BF,
                                      ).withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AlterarSenhaPage(),
                                        ),
                                      );
                                    },
                                    child: const Center(
                                      child: Text(
                                        'Alterar Senha',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(height: 32),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withValues(alpha: 0.03),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.chevron_left,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _signOut,
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Sair',
                                            style: TextStyle(
                                              color: Color(0xFFEF4444),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEE2E2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.logout,
                                              color: Color(0xFFEF4444),
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
