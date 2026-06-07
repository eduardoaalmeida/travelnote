import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navbar.dart';
import 'roteiro_page.dart';
import 'viagem_model.dart';

class DetalhesViagemPage extends StatefulWidget {
  final Viagem viagem;

  const DetalhesViagemPage({super.key, required this.viagem});

  @override
  State<DetalhesViagemPage> createState() => _DetalhesViagemPageState();
}

class _DetalhesViagemPageState extends State<DetalhesViagemPage> {
  // ── Abas ──────────────────────────────────────────────────────────────────
  int abaSelecionada = 0;
  final abas = ['Roteiro', 'Compromissos', 'Anotações'];

  // ── Dados carregados do Firestore ─────────────────────────────────────────
  List<Map<String, String>> roteiroItems = [];
  List<Map<String, String>> compromissosItems = [];
  List<Map<String, String>> anotacoesItems = [];

  // ── Streams em tempo real (um por subcoleção) ─────────────────────────────
  StreamSubscription<QuerySnapshot>? _subRoteiro;
  StreamSubscription<QuerySnapshot>? _subCompromissos;
  StreamSubscription<QuerySnapshot>? _subAnotacoes;

  // ── Referência base: viagens/{id} ─────────────────────────────────────────
  // Segue o padrão de viagens_page.dart — coleção raiz 'viagens' + doc.id
  late final DocumentReference _viagemRef;

  // ── Estado de carregamento global ─────────────────────────────────────────
  bool _carregando = false;

  // ── Getters de exibição (lidos do objeto Viagem recebido) ─────────────────
  String get nomeViagem => widget.viagem.destino;
  String get periodoViagem => widget.viagem.periodo;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _viagemRef = FirebaseFirestore.instance
        .collection('viagens')
        .doc(widget.viagem.id);

    _assinarRoteiro();
    _assinarCompromissos();
    _assinarAnotacoes();
  }

  @override
  void dispose() {
    _subRoteiro?.cancel();
    _subCompromissos?.cancel();
    _subAnotacoes?.cancel();
    super.dispose();
  }

  // ── Streams em tempo real ─────────────────────────────────────────────────

  void _assinarRoteiro() {
    _subRoteiro = _viagemRef
        .collection('roteiro')
        .orderBy('ordem')
        .snapshots()
        .listen((snap) {
          if (!mounted) return;
          setState(() {
            roteiroItems = snap.docs.map((d) {
              final data = d.data();
              return {
                'id': d.id,
                'titulo': (data['titulo'] ?? '') as String,
                'subtitulo': (data['subtitulo'] ?? '') as String,
              };
            }).toList();
          });
        });
  }

  void _assinarCompromissos() {
    _subCompromissos = _viagemRef
        .collection('compromissos')
        .orderBy('ordem')
        .snapshots()
        .listen((snap) {
          if (!mounted) return;
          setState(() {
            compromissosItems = snap.docs.map((d) {
              final data = d.data();
              return {
                'id': d.id,
                'titulo': (data['titulo'] ?? '') as String,
                'subtitulo': (data['subtitulo'] ?? '') as String,
              };
            }).toList();
          });
        });
  }

  void _assinarAnotacoes() {
    _subAnotacoes = _viagemRef
        .collection('anotacoes')
        .orderBy('ordem')
        .snapshots()
        .listen((snap) {
          if (!mounted) return;
          setState(() {
            anotacoesItems = snap.docs.map((d) {
              final data = d.data();
              return {
                'id': d.id,
                'titulo': (data['titulo'] ?? '') as String,
                'subtitulo': (data['subtitulo'] ?? '') as String,
              };
            }).toList();
          });
        });
  }

  // ── CRUD genérico ─────────────────────────────────────────────────────────

  String _nomeSubcolecao(int aba) {
    if (aba == 0) return 'roteiro';
    if (aba == 1) return 'compromissos';
    return 'anotacoes';
  }

  List<Map<String, String>> _listaAtual(int aba) {
    if (aba == 0) return roteiroItems;
    if (aba == 1) return compromissosItems;
    return anotacoesItems;
  }

  /// CREATE — adiciona documento na subcoleção correspondente
  Future<void> _criarItem({
    required int aba,
    required String titulo,
    required String subtitulo,
  }) async {
    if (titulo.isEmpty) return;
    setState(() => _carregando = true);
    try {
      final colecao = _nomeSubcolecao(aba);
      final lista = _listaAtual(aba);
      final email = FirebaseAuth.instance.currentUser?.email ?? '';

      await _viagemRef.collection(colecao).add({
        'titulo': titulo,
        'subtitulo': subtitulo,
        'ordem': lista.length, // posição na lista
        'criado_por': email,
        'criado_em': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  /// UPDATE — atualiza título e subtítulo pelo docId
  Future<void> _atualizarItem({
    required int aba,
    required String docId,
    required String titulo,
    required String subtitulo,
  }) async {
    if (titulo.isEmpty) return;
    setState(() => _carregando = true);
    try {
      await _viagemRef.collection(_nomeSubcolecao(aba)).doc(docId).update({
        'titulo': titulo,
        'subtitulo': subtitulo,
        'atualizado_em': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  /// DELETE — remove documento pelo docId
  Future<void> _excluirItem({required int aba, required String docId}) async {
    setState(() => _carregando = true);
    try {
      await _viagemRef.collection(_nomeSubcolecao(aba)).doc(docId).delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item excluído com sucesso!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _cabecalho(),
            _cardViagem(),
            _abas(),
            if (_carregando)
              const LinearProgressIndicator(
                color: Color(0xFF23D2B5),
                minHeight: 2,
              ),
            Expanded(child: _conteudo()),
            _botoes(),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 3),
    );
  }

  // ── Cabeçalho ─────────────────────────────────────────────────────────────
  Widget _cabecalho() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 18, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/logo_completa.png',
                height: 55,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Travel',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const TextSpan(
                        text: 'Note',
                        style: TextStyle(
                          color: Color(0xFF23D2B5),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ── Card da viagem ────────────────────────────────────────────────────────
  Widget _cardViagem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.viagem.imagemUrl,
              width: 90,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 90,
                height: 80,
                color: const Color(0xFFE0F2FE),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFF23D2B5),
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomeViagem,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  periodoViagem,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF2DD4BF),
            size: 28,
          ),
        ],
      ),
    );
  }

  // ── Abas ──────────────────────────────────────────────────────────────────
  Widget _abas() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(abas.length, (index) {
          final selecionada = abaSelecionada == index;
          return GestureDetector(
            onTap: () => setState(() => abaSelecionada = index),
            child: Column(
              children: [
                Text(
                  abas[index],
                  style: TextStyle(
                    color: selecionada
                        ? const Color(0xFF0D9488)
                        : const Color(0xFF94A3B8),
                    fontWeight: selecionada ? FontWeight.bold : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 35,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: selecionada
                        ? const Color(0xFF0D9488)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Conteúdo da aba ───────────────────────────────────────────────────────
  Widget _conteudo() {
    if (abaSelecionada == 0) return _roteiro();
    if (abaSelecionada == 1) return _compromissos();
    return _anotacoes();
  }

  Widget _roteiro() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Roteiro ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextSpan(
                text: '(${roteiroItems.length} dias)',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D9488),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...List.generate(roteiroItems.length, (i) {
          final item = roteiroItems[i];
          return _item(
            (i + 1).toString().padLeft(2, '0'),
            item['titulo'] ?? '',
            item['subtitulo'] ?? '',
            clicavel: true,
            index: i,
          );
        }),
        const SizedBox(height: 10),
        _botaoAdicionar('Adicionar Roteiro +'),
      ],
    );
  }

  Widget _compromissos() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Compromissos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 18),
        ...List.generate(compromissosItems.length, (i) {
          final item = compromissosItems[i];
          return _item(
            (i + 1).toString().padLeft(2, '0'),
            item['titulo'] ?? '',
            item['subtitulo'] ?? '',
            clicavel: true,
            index: i,
          );
        }),
        const SizedBox(height: 10),
        _botaoAdicionar('Adicionar Compromisso +'),
      ],
    );
  }

  Widget _anotacoes() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Anotações',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 18),
        ...List.generate(anotacoesItems.length, (i) {
          final item = anotacoesItems[i];
          return _item(
            (i + 1).toString().padLeft(2, '0'),
            item['titulo'] ?? '',
            item['subtitulo'] ?? '',
            clicavel: true,
            index: i,
          );
        }),
        const SizedBox(height: 10),
        _botaoAdicionar('Adicionar Anotação +'),
      ],
    );
  }

  // ── Item de lista ─────────────────────────────────────────────────────────
  Widget _item(
    String numero,
    String titulo,
    String subtitulo, {
    bool clicavel = true,
    int? index,
  }) {
    return InkWell(
      onTap: clicavel
          ? () {
              if (abaSelecionada == 0) {
                final item = index != null ? roteiroItems[index] : null;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoteiroPage(
                      viagem: widget.viagem,
                      roteiroId: item?['id'],
                      roteiroTitulo: item?['titulo'],
                      roteiroSubtitulo: item?['subtitulo'],
                    ),
                  ),
                );
              } else {
                _openEditor(
                  aba: abaSelecionada,
                  titulo: titulo,
                  subtitulo: subtitulo,
                  isNew: false,
                  index: index,
                );
              }
            }
          : null,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                numero,
                style: const TextStyle(
                  color: Color(0xFF0284C7),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              abaSelecionada == 0 ? Icons.chevron_right : Icons.edit_outlined,
              size: 20,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  // ── Modal de edição / cadastro ────────────────────────────────────────────
  void _openEditor({
    required int aba,
    String? titulo,
    String? subtitulo,
    bool isNew = false,
    int? index,
  }) {
    // docId só existe para itens já salvos no Firestore
    final String? docId = (!isNew && index != null)
        ? _listaAtual(aba)[index]['id']
        : null;

    final titleController = TextEditingController(text: titulo ?? '');
    final subtitleController = TextEditingController(text: subtitulo ?? '');
    final horaController = TextEditingController();

    final configs = [
      {
        'tipo': 'Dia',
        'labelTitulo': 'TÍTULO',
        'labelSub': 'LOCAL E HORÁRIO',
        'hintTitulo': 'Ex: Dia 10',
        'hintSub': 'Ex: Torre Eiffel • 09:00',
        'iconeTitulo': Icons.calendar_today_outlined,
        'iconeSub': Icons.location_on_outlined,
        'maxLinesSub': 1,
      },
      {
        'tipo': 'Compromisso',
        'labelTitulo': 'TÍTULO',
        'labelSub': 'DATA E HORÁRIO',
        'hintTitulo': isNew ? 'Título do Compromisso' : 'Jantar com Amigos',
        'hintSub': 'Ex: 11/06/2026 • 19:30',
        'iconeTitulo': Icons.location_on_outlined,
        'iconeSub': Icons.access_time_outlined,
        'maxLinesSub': 1,
      },
      {
        'tipo': 'Anotação',
        'labelTitulo': 'TÍTULO',
        'labelSub': 'DESCRIÇÃO',
        'hintTitulo': 'Ex: Restaurante X',
        'hintSub': 'Ex: Ótimo restaurante próximo à Torre Eiffel...',
        'iconeTitulo': Icons.edit_note_outlined,
        'iconeSub': Icons.description_outlined,
        'maxLinesSub': 4,
      },
    ];

    final c = configs[aba];
    final tipo = c['tipo'] as String;
    final labelTitulo = c['labelTitulo'] as String;
    final labelSub = c['labelSub'] as String;
    final hintTitulo = c['hintTitulo'] as String;
    final hintSub = c['hintSub'] as String;
    final iconeTitulo = c['iconeTitulo'] as IconData;
    final iconeSub = c['iconeSub'] as IconData;
    final maxLinesSub = c['maxLinesSub'] as int;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    isNew ? 'Cadastro de $tipo' : 'Editar $tipo',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _labelPopup(labelTitulo),
                _campoPopup(
                  controller: titleController,
                  hint: hintTitulo,
                  icone: iconeTitulo,
                  maxLines: 1,
                ),
                const SizedBox(height: 14),

                if (aba == 1) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _labelPopup('DATA'),
                            _campoPopup(
                              controller: subtitleController,
                              hint: '10/06/2026',
                              icone: Icons.calendar_today_outlined,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _labelPopup('HORÁRIO'),
                            _campoPopup(
                              controller: horaController,
                              hint: '09:30hrs',
                              icone: Icons.access_time_outlined,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  _labelPopup(labelSub),
                  _campoPopup(
                    controller: subtitleController,
                    hint: hintSub,
                    icone: iconeSub,
                    maxLines: maxLinesSub,
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final savedTitle = titleController.text.trim();
                      String savedSub = subtitleController.text.trim();

                      // Compromissos: concatena data + horário
                      if (aba == 1 && horaController.text.trim().isNotEmpty) {
                        savedSub = '$savedSub • ${horaController.text.trim()}';
                      }

                      if (savedTitle.isEmpty) return;

                      Navigator.of(ctx).pop();

                      // ── Persiste no Firestore ─────────────────────
                      if (isNew) {
                        await _criarItem(
                          aba: aba,
                          titulo: savedTitle,
                          subtitulo: savedSub,
                        );
                      } else if (docId != null) {
                        await _atualizarItem(
                          aba: aba,
                          docId: docId,
                          titulo: savedTitle,
                          subtitulo: savedSub,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF23D2B5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isNew ? 'Cadastrar $tipo' : 'Editar $tipo',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Botão excluir item — aparece só na edição
                if (!isNew && docId != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await _excluirItem(aba: aba, docId: docId);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Excluir item',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers de UI ─────────────────────────────────────────────────────────
  Widget _labelPopup(String texto) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      texto,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade500,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _campoPopup({
    required TextEditingController controller,
    required String hint,
    required IconData icone,
    int maxLines = 1,
  }) => TextField(
    controller: controller,
    maxLines: maxLines,
    style: TextStyle(
      fontSize: 14,
      color: Theme.of(context).colorScheme.onSurface,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      prefixIcon: Icon(icone, color: const Color(0xFF23D2B5), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF23D2B5), width: 1.5),
      ),
    ),
  );

  Widget _botaoAdicionar(String texto) {
    return InkWell(
      onTap: () => _openEditor(
        aba: abaSelecionada,
        titulo: '',
        subtitulo: '',
        isNew: true,
      ),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ── Botões rodapé ─────────────────────────────────────────────────────────
  Widget _botoes() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 5, 18, 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoteiroPage(viagem: widget.viagem),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                backgroundColor: Theme.of(context).cardColor,
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Editar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              // Excluir todos os itens da aba atual com confirmação
              onPressed: () => _confirmarExcluirAba(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF3D1515)
                    : const Color(0xFFFEE2E2),
                side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Excluir',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Confirma e exclui todos os itens da aba visível (comportamento original)
  void _confirmarExcluirAba() {
    final lista = _listaAtual(abaSelecionada);
    if (lista.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum item para excluir.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final tipo = abaSelecionada == 0
        ? 'Roteiro'
        : abaSelecionada == 1
        ? 'Compromissos'
        : 'Anotações';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Excluir $tipo'),
        content: Text(
          'Todos os itens de "$tipo" desta viagem serão excluídos. Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _carregando = true);
              try {
                // Exclui todos os docs da subcoleção em batch
                final colecao = _nomeSubcolecao(abaSelecionada);
                final snap = await _viagemRef.collection(colecao).get();
                final batch = FirebaseFirestore.instance.batch();
                for (final doc in snap.docs) {
                  batch.delete(doc.reference);
                }
                await batch.commit();

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$tipo excluído com sucesso!'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir: $e'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } finally {
                if (mounted) setState(() => _carregando = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Excluir tudo'),
          ),
        ],
      ),
    );
  }
}
