import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'carregamento_page.dart';
import 'agenda_page.dart';
import 'editar_perfil_page.dart';
import 'configuracoes_page.dart';
import 'alterar_dados_page.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.lightBlueAccent),
      home: const CarregamentoPage(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
    );
  }
}
