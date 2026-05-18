import 'package:flutter/material.dart';
import 'login_page.dart';

class CarregamentoPage extends StatefulWidget {
  const CarregamentoPage({super.key});

  @override
  State<CarregamentoPage> createState() => _CarregamentoPageState();
}

class _CarregamentoPageState extends State<CarregamentoPage> {
  void _irParaLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _irParaLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _irParaLogin,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Image.asset('assets/images/carregamento.png'),
            ),
            const Positioned(
              bottom: 60,
              child: CircularProgressIndicator(
                color: Color(0xFF2DD4BF),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
