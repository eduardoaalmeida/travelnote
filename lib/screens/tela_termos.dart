import 'package:flutter/material.dart';

class TelaTermos extends StatelessWidget {
  const TelaTermos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Política de Privacidade',
          style: TextStyle(
            color: Colors.black, // Cor alterada para preto
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: const Text(
            "Textos de Politica de Privacidade. Coletamos informações que você nos fornece diretamente, como ao criar uma conta, criar notas de viagem ou sincronizar seu calendário. Isso pode incluir nome, endereço de e-mail e preferências de viagem.\n\n"
            "Textos de Politica de Privacidade. Coletamos informações que você nos fornece diretamente, como ao criar uma conta, criar notas de viagem ou sincronizar seu calendário. Isso pode incluir nome, endereço de e-mail e preferências de viagem.\n\n"
            "Textos de Politica de Privacidade. Coletamos informações que você nos fornece diretamente, como ao criar uma conta, criar notas de viagem ou sincronizar seu calendário. Isso pode incluir nome, endereço de e-mail e preferências de viagem.\n\n"
            "Textos de Politica de Privacidade. Coletamos informações que você nos fornece diretamente, como ao criar uma conta, criar notas de viagem ou sincronizar seu calendário. Isso pode incluir nome, endereço de e-mail e preferências de viagem.\n\n"
            "Textos de Politica de Privacidade. Coletamos informações que você nos fornece diretamente, como ao criar uma conta, criar notas de viagem ou sincronizar seu calendário. Isso pode incluir nome, endereço de e-mail e preferências de viagem.\n\n"
            "Textos de Politica de Privacidade. Coletamos informações que você nos fornece diretamente, como ao criar uma conta, criar notas de viagem ou sincronizar seu calendário. Isso pode incluir nome, endereço de e-mail e preferências de viagem.",
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
