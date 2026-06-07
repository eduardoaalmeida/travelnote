import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'opcoes_firebase.dart';
import 'carregamento_page.dart';
import 'login_page.dart';
import 'criar_conta_page.dart';
import 'recuperar_senha_page.dart';
import 'home_page.dart';
import 'perfil_page.dart';
import 'agenda_page.dart';
import 'configuracoes_page.dart';
import 'alterar_dados_page.dart';
import 'politica_privacidade_page.dart';
import 'roteiro_page.dart';
import 'viagens_page.dart';
import 'notificacoes_page.dart';
import 'historico_viagens_page.dart';
import 'theme_notifier.dart';
import 'viagem_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: OpcoesPadraoFirebase.currentPlatform);

  runApp(const MeuApp());
}

class MeuApp extends StatefulWidget {
  const MeuApp({super.key});

  @override
  State<MeuApp> createState() => _MeuAppState();
}

class _MeuAppState extends State<MeuApp> {
  static const String telaInicial = '/';

  @override
  void initState() {
    super.initState();
    ThemeNotifier.instance.addListener(_onThemeChange);
  }

  void _onThemeChange() => setState(() {});

  @override
  void dispose() {
    ThemeNotifier.instance.removeListener(_onThemeChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeNotifier.instance.value,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.lightBlueAccent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF429EDB),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC),
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF429EDB),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF429EDB),
          onPrimary: Colors.white,
          surface: Color(0xFF111827), // fundo dos cards
          onSurface: Colors.white, // textos sobre fundo
          onSurfaceVariant: Color(0xFFCBD5E1), // textos secundários
          background: Color(0xFF0D1117), // fundo da tela (preto suave)
          onBackground: Colors.white,
          outline: Color(0xFF2D3748), // bordas/divisores
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        cardColor: const Color(0xFF111827),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1117),
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        textTheme: const TextTheme(
          bodySmall: TextStyle(color: Color(0xFFCBD5E1)),
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
        dividerColor: const Color(0xFF2D3748),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF111827),
          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
          labelStyle: const TextStyle(color: Color(0xFFCBD5E1)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2D3748)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2D3748)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF429EDB), width: 1.5),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF111827),
          selectedItemColor: Color(0xFF38BDF8),
          unselectedItemColor: Color(0xFF6B7280),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          iconColor: Colors.white70,
        ),
      ),
      initialRoute: telaInicial,
      routes: {
        '/': (_) => const CarregamentoPage(),
        '/login': (_) => const LoginPage(),
        '/criar-conta': (_) => const CriarContaPage(),
        '/recuperar': (_) => const RecuperarSenhaPage(),
        '/home': (_) => const HomePage(),
        '/perfil': (_) => const PerfilPage(),
        '/agenda': (_) => const AgendaPage(),
        '/configuracoes': (_) => const ConfiguracoesPage(),
        '/alterar-dados': (_) => const AlterarDadosPage(),
        '/politica': (_) => const PoliticaPrivacidadePage(),
        '/roteiro': (context) {
          final viagem = ModalRoute.of(context)?.settings.arguments;
          if (viagem is Viagem) {
            return RoteiroPage(viagem: viagem);
          }
          return const ViagensPage();
        },

        '/viagens': (_) => const ViagensPage(),
        '/notificacoes': (_) => const NotificacoesPage(),
        '/historico': (_) => const HistoricoViagensPage(),
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
