import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class TelaRecuperacao extends StatefulWidget {
  const TelaRecuperacao({super.key});

  @override
  State<TelaRecuperacao> createState() => _TelaRecuperacaoState();
}

class _TelaRecuperacaoState extends State<TelaRecuperacao> {
  // Máscara para o CPF
  final maskCpf = MaskTextInputFormatter(
    mask: "###.###.###-##", 
    filter: {"#": RegExp(r'[0-9]')}
  );

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Botão Voltar e Logo
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Image.asset(
                      'assets/images/logo_completa.png',
                      height: 50,
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                const Text(
                  'Recuperação De Conta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Campo CPF
                TextField(
                  inputFormatters: [maskCpf],
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Digite seu CPF cadastrado',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: const Icon(Icons.badge_outlined, color: Colors.grey, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Campo Email
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Digite seu Email cadastrado',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Botão Solicitar Senha
                ElevatedButton(
                  onPressed: () {
                    // Lógica de recuperação
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26C6DA),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Solicitar Senha',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.1),
                
                // Imagem Inferior
                Image.asset(
                  'assets/images/imagem_login.png',
                  height: 200,
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
