import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'tela_termos.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  bool _mostrarSenha = false;
  bool _mostrarConfirmarSenha = false;
  bool _aceitouTermos = false;

  // Definição das máscaras
  final maskCpf = MaskTextInputFormatter(
    mask: "###.###.###-##", 
    filter: {"#": RegExp(r'[0-9]')}
  );
  
  final maskTelefone = MaskTextInputFormatter(
    mask: "(##) #####-####", 
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Criar Conta ',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Image.asset(
                      'assets/images/icon.png',
                      height: 40,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.05),
                _buildTextField(hint: 'Nome Completo', icon: Icons.person_outline),
                const SizedBox(height: 15),
                
                // Campo CPF com Máscara
                _buildTextField(
                  hint: 'CPF', 
                  icon: Icons.badge_outlined, 
                  formatter: maskCpf,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                
                _buildTextField(hint: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 15),
                
                // Campo Telefone com Máscara
                _buildTextField(
                  hint: 'Telefone', 
                  icon: Icons.phone_android_outlined, 
                  formatter: maskTelefone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 15),
                
                _buildPasswordField(
                  hint: 'Senha',
                  isVisible: _mostrarSenha,
                  onToggle: () => setState(() => _mostrarSenha = !_mostrarSenha),
                ),
                const SizedBox(height: 15),
                _buildPasswordField(
                  hint: 'Confirme sua Senha',
                  isVisible: _mostrarConfirmarSenha,
                  onToggle: () => setState(() => _mostrarConfirmarSenha = !_mostrarConfirmarSenha),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _aceitouTermos,
                      onChanged: (value) {
                        setState(() {
                          _aceitouTermos = value ?? false;
                        });
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    const Text('Li e aceito os ', style: TextStyle(fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TelaTermos()),
                        );
                      },
                      child: const Text(
                        'Termos de Privacidade',
                        style: TextStyle(
                          color: Color(0xFF26C6DA),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2DD4BF), Color(0xFF10B981)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Lógica de cadastro
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text(
                      'Cadastrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint, 
    required IconData icon, 
    MaskTextInputFormatter? formatter,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      inputFormatters: formatter != null ? [formatter] : [],
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildPasswordField({required String hint, required bool isVisible, required VoidCallback onToggle}) {
    return TextField(
      obscureText: !isVisible,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}
