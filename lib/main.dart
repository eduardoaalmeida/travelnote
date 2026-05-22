import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'carregamento_page.dart';
import 'login_page.dart';
import 'criar_conta_page.dart';
import 'recuperar_senha_page.dart';
import 'home_page.dart';
import 'perfil_page.dart';
import 'agenda_page.dart';
import 'configuracoes_page.dart';
import 'alterar_dados_page.dart';
import 'editar_perfil_page.dart' hide HomePage; 
import 'politica_privacidade_page.dart';
import 'roteiro_page.dart';
import 'detalhes_viagem_page.dart' hide DetalhesViagemPage; 
import 'detalhes_viagem.dart';
import 'cadastrar_viagem.dart';
import 'viagens_page.dart';
import 'notificacoes_page.dart';
import 'historico_viagens_page.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  //  Troque aqui para testar uma tela específica:
  //   '/'              → carregamento
  //   '/login'         → login
  //   '/home'          → home
  //   '/viagens'       → suas viagens
  //   '/historico'     → histórico de gastos
  //   '/notificacoes'  → notificações
  //   '/roteiro'       → roteiro
  //   '/detalhes'      → detalhes da viagem
  static const String telaInicial = '/';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.lightBlueAccent),
      initialRoute: telaInicial,
      routes: {
        '/':              (_) => const CarregamentoPage(),
        '/login':         (_) => const LoginPage(),
        '/criar-conta':   (_) => const CriarContaPage(),
        '/recuperar':     (_) => const RecuperarSenhaPage(),
        '/home':          (_) => const HomePage(),
        '/perfil':        (_) => const PerfilPage(),
        '/agenda':        (_) => const AgendaPage(),
        '/configuracoes': (_) => const ConfiguracoesPage(),
        '/alterar-dados': (_) => const AlterarDadosPage(),
        '/politica':      (_) => const PoliticaPrivacidadePage(),
        '/roteiro':       (_) => const RoteiroPage(),
        '/detalhes':      (_) => const DetalhesViagemPage(),
        '/viagens':       (_) => const ViagensPage(),
        '/notificacoes':  (_) => const NotificacoesPage(),
        '/historico':     (_) => const HistoricoViagensPage(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
    );
  }
}