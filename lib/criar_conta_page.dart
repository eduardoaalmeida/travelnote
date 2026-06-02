import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'auxiliar_firebase.dart';
import 'politica_privacidade_page.dart';

class CriarContaPage extends StatefulWidget {
  const CriarContaPage({super.key});

  @override
  State<CriarContaPage> createState() => _CriarContaPageState();
}

class _CriarContaPageState extends State<CriarContaPage> {
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  bool _aceitouTermos = false;
  bool _carregando = false; // Controla o estado de salvamento

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint, IconData prefixIcon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
      prefixIcon: Icon(prefixIcon, color: Colors.grey, size: 22),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2196F3)),
      ),
    );
  }

  Widget _eyeIcon(bool visivel, VoidCallback onToggle) {
    return IconButton(
      icon: Icon(
        visivel ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Colors.grey,
        size: 22,
      ),
      onPressed: onToggle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                              onPressed: _carregando ? null : () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Criar Conta',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Image.asset('assets/images/icon.png', height: 44),
                                ],
                              ),
                            ),
                            const Spacer(flex: 2),
                            TextField(
                              controller: _nomeController,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              enabled: !_carregando,
                              decoration: _decoration('Nome Completo', Icons.person_outline),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _cpfController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_cpfFormatter],
                              enabled: !_carregando,
                              decoration: _decoration('CPF', Icons.lock_outline),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !_carregando,
                              decoration: _decoration('Email', Icons.email_outlined),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _telefoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [_telefoneFormatter],
                              enabled: !_carregando,
                              decoration: _decoration('Telefone', Icons.lock_outline),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _senhaController,
                              obscureText: !_senhaVisivel,
                              enabled: !_carregando,
                              decoration: _decoration(
                                'Senha',
                                Icons.lock_outline,
                                suffix: _eyeIcon(
                                  _senhaVisivel,
                                  () => setState(() => _senhaVisivel = !_senhaVisivel),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _confirmarSenhaController,
                              obscureText: !_confirmarSenhaVisivel,
                              enabled: !_carregando,
                              decoration: _decoration(
                                'Confirme sua Senha',
                                Icons.lock_outline,
                                suffix: _eyeIcon(
                                  _confirmarSenhaVisivel,
                                  () => setState(() => _confirmarSenhaVisivel = !_confirmarSenhaVisivel),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _aceitouTermos,
                                    onChanged: _carregando ? null : (v) => setState(() => _aceitouTermos = v ?? false),
                                    activeColor: const Color(0xFF2DD4BF),
                                    side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Li e aceito os ',
                                  style: TextStyle(fontSize: 15, color: Colors.black87),
                                ),
                                GestureDetector(
                                  onTap: _carregando ? null : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const PoliticaPrivacidadePage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Termos de Privacidade',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF2DD4BF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(flex: 3),
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2DD4BF), Color(0xFF10B981)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2DD4BF).withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _carregando ? null : () async {
                                    if (_nomeController.text.trim().isEmpty ||
                                        _cpfController.text.trim().isEmpty ||
                                        _emailController.text.trim().isEmpty ||
                                        _telefoneController.text.trim().isEmpty ||
                                        _senhaController.text.trim().isEmpty ||
                                        _confirmarSenhaController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Por favor, preencha todos os campos.'),
                                        ),
                                      );
                                      return;
                                    }
                                    final email = _emailController.text.trim();
                                    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
                                    if (!emailRegex.hasMatch(email)) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Por favor, insira um e-mail válido.'),
                                        ),
                                      );
                                      return;
                                    }
                                    if (_cpfController.text.length < 14) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Por favor, insira o CPF completo.'),
                                        ),
                                      );
                                      return;
                                    }
                                    if (_telefoneController.text.length < 15) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Por favor, insira o telefone completo.'),
                                        ),
                                      );
                                      return;
                                    }
                                    if (_senhaController.text != _confirmarSenhaController.text) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('As senhas não coincidem.'),
                                        ),
                                      );
                                      return;
                                    }
                                    if (!_aceitouTermos) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Você deve aceitar os Termos de Privacidade.'),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => _carregando = true);
                                    try {
                                       await AuxiliarFirebase.registrarUsuario(
                                         nome: _nomeController.text,
                                         email: email,
                                         cpf: _cpfController.text,
                                         telefone: _telefoneController.text,
                                         senha: _senhaController.text,
                                         aceitouTermos: _aceitouTermos,
                                       );

                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Cadastro realizado com sucesso!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                           content: Text(AuxiliarFirebase.obterMensagemErro(e)),
                                           backgroundColor: Colors.redAccent,
                                         ),
                                       );
                                    } finally {
                                      if (mounted) setState(() => _carregando = false);
                                    }
                                  },
                                  child: Center(
                                    child: _carregando
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            'Cadastrar',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
