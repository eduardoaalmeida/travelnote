import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auxiliar_firebase.dart';
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

  void _verificarUsuario() async {
    if (!mounted) return;
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario != null) {
      if (AuxiliarFirebase.isInstitutionalEmail(usuario.email ?? '')) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(usuario.uid)
              .get();
          if (doc.exists) {
            Navigator.pushReplacementNamed(context, '/home');
            return;
          }
        } catch (_) {}
      }
      await AuxiliarFirebase.logout();
    }
    _irParaLogin();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _verificarUsuario);
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
            Center(child: Image.asset('assets/images/carregamento.png')),
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
