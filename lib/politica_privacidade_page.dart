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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Política de Privacidade',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            textoPolitica,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}
