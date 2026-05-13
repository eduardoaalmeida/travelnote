import 'package:flutter/material.dart';
import 'login_page.dart';

class CarregamentoPage extends StatefulWidget {
  const CarregamentoPage({super.key});

  @override
  State<CarregamentoPage> createState() => _CarregamentoPageState();
}

class _CarregamentoPageState extends State<CarregamentoPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/carregamento.png'),
      ),
    );
  }
}
