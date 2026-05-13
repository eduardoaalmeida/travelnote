import 'package:flutter/material.dart';
import 'tela_cadastro.dart';
import 'tela_recuperacao.dart';
import 'tela_dashboard.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  bool _mostrarSenha = false; // Controle de visibilidade da senha

  @override
  Widget build(BuildContext context) {
    // Pegando as dimensões da tela para responsividade
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08), // Margem proporcional
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.05), // Espaçamento proporcional
                
                // Logo Superior
                Image.asset(
                  'assets/images/logo_completa.png',
                  height: screenHeight * 0.15, // Tamanho proporcional
                ),
                
                SizedBox(height: screenHeight * 0.06),
                
                // Campo de Email
                TextField(
                  style: const TextStyle(fontSize: 14), // Letra menor
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Digite seu Email',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.grey, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Campo de Senha
                TextField(
                  obscureText: !_mostrarSenha, // Lógica funcional de mostrar senha
                  style: const TextStyle(fontSize: 14), // Letra menor
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Digite sua Senha',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _mostrarSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _mostrarSenha = !_mostrarSenha;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // Botão Entrar
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const TelaDashboard()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    minimumSize: const Size(double.infinity, 50), // Botão um pouco mais baixo
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2DD4BF), Color(0xFF10B981)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TelaCadastro()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Criar Conta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Link Esqueceu sua senha
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TelaRecuperacao()),
                    );
                  },
                  child: const Text(
                    'Esqueceu sua senha?',
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.04),
                
                // Imagem Inferior
                Image.asset(
                  'assets/images/imagem_login.png',
                  height: screenHeight * 0.22, // Tamanho proporcional
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
