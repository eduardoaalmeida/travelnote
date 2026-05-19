import 'package:flutter/material.dart';

class RecuperarSenhaPage extends StatefulWidget {
  const RecuperarSenhaPage({super.key});

  @override
  State<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _senhaAtualVisivel = false;
  bool _novaSenhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 22),
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
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
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                                  onPressed: () => Navigator.pop(context),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 28.0), // Compensation for back button
                                      child: Image(
                                        image: AssetImage('assets/images/logo_completa.png'),
                                        height: 60,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            const Center(
                              child: Text(
                                'Alteração de Senha',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            _label('Senha Atual'),
                            TextField(
                              controller: _senhaAtualController,
                              obscureText: !_senhaAtualVisivel,
                              decoration: _decoration(
                                'Digite sua senha Atual',
                                suffix: _eyeIcon(
                                  _senhaAtualVisivel,
                                  () => setState(() => _senhaAtualVisivel = !_senhaAtualVisivel),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _label('Nova Senha'),
                            TextField(
                              controller: _novaSenhaController,
                              obscureText: !_novaSenhaVisivel,
                              decoration: _decoration(
                                'Digite sua Nova Senha',
                                suffix: _eyeIcon(
                                  _novaSenhaVisivel,
                                  () => setState(() => _novaSenhaVisivel = !_novaSenhaVisivel),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _label('Confirmar Nova Senha'),
                            TextField(
                              controller: _confirmarSenhaController,
                              obscureText: !_confirmarSenhaVisivel,
                              decoration: _decoration(
                                'Confirme a Nova Senha',
                                suffix: _eyeIcon(
                                  _confirmarSenhaVisivel,
                                  () => setState(() => _confirmarSenhaVisivel = !_confirmarSenhaVisivel),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
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
                                    color: const Color(0xFF2DD4BF).withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    // Ação de alterar senha
                                  },
                                  child: const Center(
                                    child: Text(
                                      'Alterar Senha',
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
                            const Spacer(),
                            const SizedBox(height: 20),
                            Center(
                              child: Image.asset(
                                'assets/images/imagem_login.png',
                                width: double.infinity,
                                fit: BoxFit.contain,
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
