import 'package:flutter/material.dart';
import 'dart:async';
import 'tela_login.dart';

class TelaCarregamento extends StatefulWidget {
  const TelaCarregamento({super.key});

  @override
  State<TelaCarregamento> createState() => _TelaCarregamentoState();
}

class _TelaCarregamentoState extends State<TelaCarregamento> {
  @override
  void initState() {
    super.initState();
    // Timer de 3 segundos para navegar para a tela de login
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaLogin()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/carregamento.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Padding(
              padding: EdgeInsets.only(bottom: 50.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
