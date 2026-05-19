import 'package:flutter/material.dart';

class PoliticaPrivacidadePage extends StatelessWidget {
  const PoliticaPrivacidadePage({super.key});

  @override
  Widget build(BuildContext context) {
    const String textoPolitica = 
        'Textos de Política de Privacidade. Coletamos informações que você nos fornece diretamente, como ao criar uma conta, criar notas de viagem ou sincronizar seu calendário. Isso pode incluir nome, endereço de e-mail e preferências de viagem.\n\n'
        'Textos de Política de Privacidade. Coletamos informações que você nos fornece diretamente, como ao criar uma conta, criar notas de viagem ou sincronizar seu calendário. Isso pode incluir nome, endereço de e-mail e preferências de viagem.\n\n'
        'Textos de Política de Privacidade. Coletamos informações que você nos fornece diretamente, como ao criar uma conta, criar notas de viagem ou sincronizar seu calendário. Isso pode incluir nome, endereço de e-mail e preferências de viagem.\n\n'
        'Textos de Política de Privacidade. Coletamos informações que você nos fornece diretamente, como ao criar uma conta, criar notas de viagem ou sincronizar seu calendário. Isso pode incluir nome, endereço de e-mail e preferências de viagem.\n\n'
        'Textos de Política de Privacidade. Coletamos informações que você nos fornece diretamente, como ao criar uma conta, criar notas de viagem ou sincronizar seu calendário. Isso pode incluir nome, endereço de e-mail e preferências de viagem.';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
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
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            textoPolitica,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF475569),
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}
