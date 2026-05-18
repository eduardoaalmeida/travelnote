import 'package:flutter/material.dart';
import 'navbar.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  Widget item(String titulo, String valor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo),
          Row(
            children: [
              Text(valor, style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios, size: 15),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Configurações',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            item('Idioma', 'Português'),
            item('País', 'Brasil'),
            item('Moeda', 'BRL'),
            item('Gerenciar minha conta', ''),
            item('Notificações', ''),
            item('Modo Noturno', ''),
            item('Sair da Conta', ''),
            item('Termos e Condições', ''),
            item('Versão', '1.0'),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 0),
    );
  }
}
