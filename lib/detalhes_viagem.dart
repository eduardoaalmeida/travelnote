import 'package:flutter/material.dart';
import 'navbar.dart';

class DetalhesViagemPage extends StatefulWidget {
  const DetalhesViagemPage({super.key});

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
          'subtitulo': 'LOCALIZADO PRÓXIMO À TORRE\nEIFFEL. ÓTIMO RESTAURANTE E PREÇO\nBOM'
        },
        {
          'titulo': 'Restaurante X',
          'subtitulo': 'LOCALIZADO PRÓXIMO À TORRE\nEIFFEL. ÓTIMO RESTAURANTE E PREÇO\nBOM'
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

  String get nomeViagem => viagens[viagemAtual]['nome'] ?? 'Paris';
  String get dataInicio => viagens[viagemAtual]['dataInicio'] ?? '10';
  String get dataFim => viagens[viagemAtual]['dataFim'] ?? '13';
  String get mesAno => viagens[viagemAtual]['mes'] ?? 'Jun';

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
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _cardViagem() {
    return InkWell(
      onTap: () => _openSelecionarViagem(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                    '$dataInicio à $dataFim $mesAno',
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
      ),
    );
  }

  Widget _abas() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(abas.length, (index) {
          final selecionada = abaSelecionada == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                abaSelecionada = index;
              });
            },
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
    if (abaSelecionada == 0) {
      return _roteiro();
    }

    if (abaSelecionada == 1) {
      return _compromissos();
    }

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
          final numero = (i + 1).toString().padLeft(2, '0');
          return _item(numero, item['titulo'] ?? '', item['subtitulo'] ?? '', index: i);
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
          final numero = (i + 1).toString().padLeft(2, '0');
          return _item(numero, item['titulo'] ?? '', item['subtitulo'] ?? '', editar: true, index: i);
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
          final numero = (i + 1).toString().padLeft(2, '0');
          return _item(numero, item['titulo'] ?? '', item['subtitulo'] ?? '', editar: true, index: i);
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
    bool editar = false,
    int? index,
  }) {
    return InkWell(
      onTap: () {
        _openEditor(
          aba: abaSelecionada,
          numero: numero,
          titulo: titulo,
          subtitulo: subtitulo,
          editar: editar,
          isNew: false,
          index: index,
        );
      },
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
              editar ? Icons.edit : Icons.chevron_right,
              size: 20,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

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

  void _openEditor({
    required int aba,
    String? numero,
    String? titulo,
    String? subtitulo,
    bool editar = false,
    bool isNew = false,
    int? index,
  }) {
    final titleController = TextEditingController(text: titulo ?? '');
    final subtitleController = TextEditingController(text: subtitulo ?? '');

    final tipo = aba == 0
        ? 'Dia'
        : aba == 1
            ? 'Compromisso'
            : 'Anotação';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 18,
            right: 18,
            top: 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${isNew ? 'Adicionar' : 'Editar'} $tipo',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: aba == 0 ? 'Título / Dia' : 'Título',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subtitleController,
                minLines: 1,
                maxLines: aba == 2 ? 6 : 1,
                decoration: InputDecoration(
                  labelText: aba == 1 ? 'Data / Hora' : 'Detalhes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final savedTitle = titleController.text.trim();
                      final savedSubtitle = subtitleController.text.trim();
                      Navigator.of(ctx).pop();

                      setState(() {
                        if (aba == 0) {
                          if (isNew) {
                            roteiroItems.add({'titulo': savedTitle, 'subtitulo': savedSubtitle});
                          } else if (index != null) {
                            roteiroItems[index] = {'titulo': savedTitle, 'subtitulo': savedSubtitle};
                          }
                        } else if (aba == 1) {
                          if (isNew) {
                            compromissosItems.add({'titulo': savedTitle, 'subtitulo': savedSubtitle});
                          } else if (index != null) {
                            compromissosItems[index] = {'titulo': savedTitle, 'subtitulo': savedSubtitle};
                          }
                        } else {
                          if (isNew) {
                            anotacoesItems.add({'titulo': savedTitle, 'subtitulo': savedSubtitle});
                          } else if (index != null) {
                            anotacoesItems[index] = {'titulo': savedTitle, 'subtitulo': savedSubtitle};
                          }
                        }
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isNew
                              ? '$tipo criado: $savedTitle'
                              : '$tipo atualizado: $savedTitle'),
                        ),
                      );
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }

  Widget _botoes() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 5, 18, 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _openEditarItens();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Editar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                _openExcluirItens();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.delete_outline, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openExcluirItens() {
    final tipo = abaSelecionada == 0
        ? 'Roteiro'
        : abaSelecionada == 1
            ? 'Compromissos'
            : 'Anotações';

    List<Map<String, String>> itensAttuais = abaSelecionada == 0
        ? roteiroItems
        : abaSelecionada == 1
            ? compromissosItems
            : anotacoesItems;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Excluir $tipo',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: itensAttuais.length,
                  itemBuilder: (_, i) {
                    final item = itensAttuais[i];
                    final numero = (i + 1).toString().padLeft(2, '0');
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: InkWell(
                        onTap: () {
                          showDialog<void>(
                            context: ctx,
                            builder: (confirmCtx) => AlertDialog(
                              title: const Text('Confirmar exclusão'),
                              content: Text(
                                'Tem certeza que deseja excluir "${item['titulo']}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(confirmCtx).pop(),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(confirmCtx).pop();
                                    Navigator.of(ctx).pop();
                                    setState(() {
                                      itensAttuais.removeAt(i);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '"${item['titulo']}" excluído(a)',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Excluir',
                                    style: TextStyle(color: Color(0xFFEF4444)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
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
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['titulo'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['subtitulo'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Color(0xFFEF4444),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEditarItens() {
    final tipo = abaSelecionada == 0
        ? 'Roteiro'
        : abaSelecionada == 1
            ? 'Compromissos'
            : 'Anotações';

    List<Map<String, String>> itensAttuais = abaSelecionada == 0
        ? roteiroItems
        : abaSelecionada == 1
            ? compromissosItems
            : anotacoesItems;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editar $tipo',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: itensAttuais.length,
                  itemBuilder: (_, i) {
                    final item = itensAttuais[i];
                    final numero = (i + 1).toString().padLeft(2, '0');
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _openEditor(
                            aba: abaSelecionada,
                            numero: numero,
                            titulo: item['titulo'] ?? '',
                            subtitulo: item['subtitulo'] ?? '',
                            editar: true,
                            isNew: false,
                            index: i,
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
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
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['titulo'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['subtitulo'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.edit,
                                size: 18,
                                color: Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSelecionarViagem() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'Minhas Viagens',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: viagens.length,
                  itemBuilder: (_, i) {
                    final viagem = viagens[i];
                    final selecionada = viagemAtual == i;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _carregarViagem(i);
                          });
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Viagem selecionada: ${viagem['nome']}'),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selecionada ? const Color(0xFFE0F2FE) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selecionada ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  viagem['imagem'] ?? 'assets/images/paris.png',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      viagem['nome'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: selecionada ? const Color(0xFF0284C7) : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${viagem['dataInicio']} à ${viagem['dataFim']} ${viagem['mes']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selecionada)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF0284C7),
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _openAdicionarViagem();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _openExcluirViagem();
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Excluir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Fechar'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _openAdicionarViagem() {
    final nomeController = TextEditingController();
    final dataInicioController = TextEditingController();
    final dataFimController = TextEditingController();
    final mesController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 18,
            right: 18,
            top: 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adicionar Nova Viagem',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome do País',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dataInicioController,
                      decoration: InputDecoration(
                        labelText: 'Dia Início',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: dataFimController,
                      decoration: InputDecoration(
                        labelText: 'Dia Fim',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: mesController,
                      decoration: InputDecoration(
                        labelText: 'Mês',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final nome = nomeController.text.trim();
                      final inicio = dataInicioController.text.trim();
                      final fim = dataFimController.text.trim();
                      final mes = mesController.text.trim();

                      if (nome.isEmpty || inicio.isEmpty || fim.isEmpty || mes.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Preencha todos os campos')),
                        );
                        return;
                      }

                      setState(() {
                        viagens.add({
                          'nome': nome,
                          'dataInicio': inicio,
                          'dataFim': fim,
                          'mes': mes,
                          'imagem': 'assets/images/paris.png',
                          'roteiro': [],
                          'compromissos': [],
                          'anotacoes': [],
                        });
                        _carregarViagem(viagens.length - 1);
                      });

                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Viagem "$nome" adicionada')),
                      );
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }

  void _openExcluirViagem() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'Excluir Viagem',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: viagens.length,
                  itemBuilder: (_, i) {
                    final viagem = viagens[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: InkWell(
                        onTap: () {
                          showDialog<void>(
                            context: ctx,
                            builder: (confirmCtx) => AlertDialog(
                              title: const Text('Confirmar exclusão'),
                              content: Text(
                                'Tem certeza que deseja excluir "${viagem['nome']}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(confirmCtx).pop(),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(confirmCtx).pop();
                                    Navigator.of(ctx).pop();
                                    setState(() {
                                      viagens.removeAt(i);
                                      if (viagemAtual >= viagens.length && viagens.isNotEmpty) {
                                        _carregarViagem(viagens.length - 1);
                                      } else if (viagens.isNotEmpty) {
                                        _carregarViagem(0);
                                      }
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('"${viagem['nome']}" excluída'),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Excluir',
                                    style: TextStyle(color: Color(0xFFEF4444)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  viagem['imagem'] ?? 'assets/images/paris.png',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      viagem['nome'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${viagem['dataInicio']} à ${viagem['dataFim']} ${viagem['mes']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Color(0xFFEF4444),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEditorViagem() {
    final nomeController = TextEditingController(text: nomeViagem);
    final dataInicioController = TextEditingController(text: dataInicio);
    final dataFimController = TextEditingController(text: dataFim);
    final mesAnoController = TextEditingController(text: mesAno);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 18,
            right: 18,
            top: 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Editar Viagem',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome da Viagem',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dataInicioController,
                      decoration: InputDecoration(
                        labelText: 'Dia Início',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: dataFimController,
                      decoration: InputDecoration(
                        labelText: 'Dia Fim',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: mesAnoController,
                      decoration: InputDecoration(
                        labelText: 'Mês',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _atualizarViagem(
                        nomeController.text.trim(),
                        dataInicioController.text.trim(),
                        dataFimController.text.trim(),
                        mesAnoController.text.trim(),
                      );
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Viagem atualizada')),
                      );
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }
}