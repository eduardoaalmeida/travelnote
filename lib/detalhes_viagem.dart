import 'package:flutter/material.dart';
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
  int abaSelecionada = 0;
  final abas = ['Roteiro', 'Compromissos', 'Anotações'];
  int viagemAtual = 0;

  List<Map<String, dynamic>> viagens = [
    {
      'nome': 'Paris',
      'dataInicio': '10',
      'dataFim': '13',
      'mes': 'Jun',
      'imagem': 'assets/images/paris.png',
      'roteiro': [
        {'titulo': 'Dia 10', 'subtitulo': 'TORRE EIFFEL • 09:00'},
        {'titulo': 'Dia 11', 'subtitulo': 'TORRE EIFFEL • 09:00'},
        {'titulo': 'Dia 12', 'subtitulo': 'TORRE EIFFEL • 09:00'},
        {'titulo': 'Dia 13', 'subtitulo': 'TORRE EIFFEL • 09:00'},
      ],
      'compromissos': [
        {'titulo': 'Jantar com Amigos', 'subtitulo': '11/06/2026 • 19:30HRS'},
        {'titulo': 'Reunião de Negócios', 'subtitulo': '11/06/2026 • 11:00HRS'},
        {'titulo': 'Compromisso 3', 'subtitulo': '13/06/2026 • 09:00HRS'},
      ],
      'anotacoes': [
        {
          'titulo': 'Restaurante X',
          'subtitulo':
              'LOCALIZADO PRÓXIMO À TORRE\nEIFFEL. ÓTIMO RESTAURANTE E PREÇO\nBOM',
        },
        {
          'titulo': 'Restaurante X',
          'subtitulo':
              'LOCALIZADO PRÓXIMO À TORRE\nEIFFEL. ÓTIMO RESTAURANTE E PREÇO\nBOM',
        },
      ],
    },
  ];

  late List<Map<String, String>> roteiroItems;
  late List<Map<String, String>> compromissosItems;
  late List<Map<String, String>> anotacoesItems;

  @override
  void initState() {
    super.initState();
    _carregarViagem(0);
  }

  void _carregarViagem(int index) {
    if (index >= 0 && index < viagens.length) {
      viagemAtual = index;
      roteiroItems = List<Map<String, String>>.from(
        viagens[index]['roteiro'] as List<dynamic>,
      );
      compromissosItems = List<Map<String, String>>.from(
        viagens[index]['compromissos'] as List<dynamic>,
      );
      anotacoesItems = List<Map<String, String>>.from(
        viagens[index]['anotacoes'] as List<dynamic>,
      );
    }
  }

  String get nomeViagem => widget.viagem.destino;
  String get dataInicio => widget.viagem.dataInicio;
  String get dataFim => widget.viagem.dataFim;
  String get mesAno => '';

  void _atualizarViagem(String nome, String inicio, String fim, String mes) {
    setState(() {
      viagens[viagemAtual]['nome'] = nome;
      viagens[viagemAtual]['dataInicio'] = inicio;
      viagens[viagemAtual]['dataFim'] = fim;
      viagens[viagemAtual]['mes'] = mes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _cabecalho(),
            _cardViagem(),
            _abas(),
            Expanded(child: _conteudo()),
            _botoes(),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 3),
    );
  }

  Widget _cabecalho() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 18, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/logo_completa.png',
                height: 55,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Travel',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
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

  Widget _cardViagem() {
    final content = Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              viagens[viagemAtual]['imagem'] ?? 'assets/images/paris.png',
              width: 90,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 80,
                color: const Color(0xFFE0F2FE),
                child: const Icon(
                  Icons.flight,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.viagem.periodo,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
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

    return content;
  }

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
              const TextSpan(
                text: 'Roteiro ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
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
      ],
    );
  }

  Widget _compromissos() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Compromissos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
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
        const Text(
          'Anotações',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RoteiroPage()),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
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

  void _openEditor({
    required int aba,
    String? titulo,
    String? subtitulo,
    bool isNew = false,
    int? index,
  }) {
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
        backgroundColor: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
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
                    onPressed: () {
                      final savedTitle = titleController.text.trim();
                      String savedSub = subtitleController.text.trim();

                      if (aba == 1 && horaController.text.trim().isNotEmpty) {
                        savedSub = '$savedSub • ${horaController.text.trim()}';
                      }

                      if (savedTitle.isEmpty) return;

                      Navigator.of(ctx).pop();

                      setState(() {
                        final novoItem = {
                          'titulo': savedTitle,
                          'subtitulo': savedSub,
                        };

                        if (aba == 0) {
                          if (isNew) {
                            roteiroItems.add(novoItem);
                          } else if (index != null) {
                            roteiroItems[index] = novoItem;
                          }
                        } else if (aba == 1) {
                          if (isNew) {
                            compromissosItems.add(novoItem);
                          } else if (index != null) {
                            compromissosItems[index] = novoItem;
                          }
                        } else {
                          if (isNew) {
                            anotacoesItems.add(novoItem);
                          } else if (index != null) {
                            anotacoesItems[index] = novoItem;
                          }
                        }
                      });
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
              ],
            ),
          ),
        ),
      ),
    );
  }

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
    style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
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
      onTap: () {
        _openEditor(
          aba: abaSelecionada,
          titulo: '',
          subtitulo: '',
          isNew: true,
        );
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _botoes() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 5, 18, 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RoteiroPage()),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0F172A)),
                  SizedBox(width: 8),
                  Text(
                    'Editar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                backgroundColor: const Color(0xFFFEE2E2),
                side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Excluir',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Color(0xFF0F172A),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
