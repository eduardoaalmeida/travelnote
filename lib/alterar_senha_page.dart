import 'package:flutter/material.dart';
import 'auxiliar_firebase.dart';

class AlterarSenhaPage extends StatefulWidget {
  const AlterarSenhaPage({super.key});

  @override
  State<AlterarSenhaPage> createState() => _AlterarSenhaPageState();
}

class _AlterarSenhaPageState extends State<AlterarSenhaPage> {
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _senhaAtualVisivel = false;
  bool _novaSenhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  bool _carregando = false;
  bool? _isGoogleUser;

  @override
  void initState() {
    super.initState();
    _verificarProvedor();
  }

  void _verificarProvedor() async {
    final isGoogle = await AuxiliarFirebase.isGoogleUser();
    if (mounted) {
      setState(() {
        _isGoogleUser = isGoogle;
      });
    }
  }

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(
    BuildContext context,
    String hint, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey, size: 22),
      suffixIcon: suffix,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: EdgeInsets.symmetric(vertical: 18),
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
    if (_isGoogleUser == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    size: 28,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 28.0),
                                      child: Image(
                                        image: AssetImage(
                                          'assets/images/logo_completa.png',
                                        ),
                                        height: 60,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Center(
                              child: Text(
                                'Alteração de Senha',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            if (_isGoogleUser!) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withValues(alpha: 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF1F5F9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.vpn_key_outlined,
                                        size: 40,
                                        color: Color(0xFF1B4E88),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Login pelo Google',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Sua conta está conectada através do Google Sign-In. Portanto, você não possui uma senha local para alterar neste aplicativo.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      width: double.infinity,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF2DD4BF),
                                            Color(0xFF10B981),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          onTap: () => Navigator.pop(context),
                                          child: const Center(
                                            child: Text(
                                              'Voltar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              _label('Senha Atual'),
                              TextField(
                                controller: _senhaAtualController,
                                obscureText: !_senhaAtualVisivel,
                                enabled: !_carregando,
                                decoration: _decoration(
                                  context,
                                  'Digite sua senha Atual',
                                  suffix: _eyeIcon(
                                    _senhaAtualVisivel,
                                    () => setState(
                                      () => _senhaAtualVisivel =
                                          !_senhaAtualVisivel,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _label('Nova Senha'),
                              TextField(
                                controller: _novaSenhaController,
                                obscureText: !_novaSenhaVisivel,
                                enabled: !_carregando,
                                decoration: _decoration(
                                  context,
                                  'Digite sua Nova Senha',
                                  suffix: _eyeIcon(
                                    _novaSenhaVisivel,
                                    () => setState(
                                      () => _novaSenhaVisivel =
                                          !_novaSenhaVisivel,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _label('Confirmar Nova Senha'),
                              TextField(
                                controller: _confirmarSenhaController,
                                obscureText: !_confirmarSenhaVisivel,
                                enabled: !_carregando,
                                decoration: _decoration(
                                  context,
                                  'Confirme a Nova Senha',
                                  suffix: _eyeIcon(
                                    _confirmarSenhaVisivel,
                                    () => setState(
                                      () => _confirmarSenhaVisivel =
                                          !_confirmarSenhaVisivel,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
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
                                  borderRadius: BorderRadius.circular(12),
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
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: _carregando
                                        ? null
                                        : () async {
                                            final senhaAtual =
                                                _senhaAtualController.text;
                                            final novaSenha =
                                                _novaSenhaController.text;
                                            final confirmarSenha =
                                                _confirmarSenhaController.text;

                                            if (senhaAtual.isEmpty ||
                                                novaSenha.isEmpty ||
                                                confirmarSenha.isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Por favor, preencha todos os campos.',
                                                  ),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                              );
                                              return;
                                            }

                                            if (novaSenha != confirmarSenha) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'A nova senha e a confirmação não coincidem.',
                                                  ),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                              );
                                              return;
                                            }

                                            if (novaSenha.length < 6) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'A nova senha deve conter pelo menos 6 caracteres.',
                                                  ),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                              );
                                              return;
                                            }

                                            setState(() => _carregando = true);
                                            try {
                                              await AuxiliarFirebase.alterarSenha(
                                                senhaAtual: senhaAtual,
                                                novaSenha: novaSenha,
                                              );

                                              if (!mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Senha alterada com sucesso!',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );

                                              _senhaAtualController.clear();
                                              _novaSenhaController.clear();
                                              _confirmarSenhaController.clear();

                                              Navigator.pop(context);
                                            } catch (e) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    AuxiliarFirebase.obterMensagemErro(
                                                      e,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                              );
                                            } finally {
                                              if (mounted) {
                                                setState(
                                                  () => _carregando = false,
                                                );
                                              }
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
                            ],
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
