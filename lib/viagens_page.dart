import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'viagem_model.dart';
import 'historico_viagens_page.dart';
import 'navbar.dart';
import 'home_page.dart';

final List<Viagem> viagensMock = [];

class ViagensPage extends StatefulWidget {
  const ViagensPage({super.key});

  @override
  State<ViagensPage> createState() => _ViagensPageState();
}

class _ViagensPageState extends State<ViagensPage> {
  List<Viagem> _viagens = [];
  StreamSubscription<QuerySnapshot>? _subscription;

  int? _expandidoIndex;
  int _filtroBotao = 0;
  final _filtros = ['Data', 'Destino', 'Tipo'];

  String _periodoInicio = '01/01/2026';
  String _periodoFim = '31/12/2026';
  final _buscaDestinoController = TextEditingController();
  String? _tipoSelecionado = 'Todos';
  final List<String> _tiposDisponiveis = [
    'Todos',
    'Lazer',
    'Trabalho',
    'Família',
    'Negócios',
  ];

  final _destinoController = TextEditingController();
  final _inicioController = TextEditingController();
  final _fimController = TextEditingController();
  final _orcamentoController = TextEditingController();
  final _anotacoesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    _subscription = FirebaseFirestore.instance
        .collection('viagens')
        .where('usuarioId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;
          setState(() {
            viagensMock.clear();
            for (var doc in snapshot.docs) {
              final data = doc.data() as Map<String, dynamic>;
              String converterData(dynamic valor) {
                if (valor is Timestamp) {
                  final d = valor.toDate();
                  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
                }
                return valor?.toString() ?? '';
              }

              viagensMock.add(
                Viagem(
                  id: doc.id,
                  destino: data['destino'] ?? '',
                  imagemUrl:
                      data['imagemUrl'] ??
                      'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
                  dataInicio: converterData(data['dataInicio']),
                  dataFim: converterData(data['dataFim']),
                  orcamento: data['orcamento'] ?? '',
                  anotacoes: data['anotacoes'] ?? '',
                  tipo: data['tipo'] ?? 'Lazer',
                  confirmada: data['confirmada'] ?? true,
                ),
              );
            }
            _aplicarFiltros();
          });
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _buscaDestinoController.dispose();
    _destinoController.dispose();
    _inicioController.dispose();
    _fimController.dispose();
    _orcamentoController.dispose();
    _anotacoesController.dispose();
    super.dispose();
  }

  void _aplicarFiltros() {
    setState(() {
      _expandidoIndex = null;

      _viagens = viagensMock.where((v) {
        if (_filtroBotao == 0) {
          return true;
        } else if (_filtroBotao == 1) {
          final busca = _buscaDestinoController.text.toLowerCase();
          return v.destino.toLowerCase().contains(busca);
        } else if (_filtroBotao == 2) {
          if (_tipoSelecionado == null || _tipoSelecionado == 'Todos')
            return true;
          return v.tipo == _tipoSelecionado;
        }
        return true;
      }).toList();
    });
  }

  IconData _getIconForTipo(String? tipo) {
    switch (tipo) {
      case 'Lazer':
        return Icons.beach_access_outlined;
      case 'Trabalho':
        return Icons.laptop_chromebook_outlined;
      case 'Família':
        return Icons.people_outline;
      case 'Negócios':
        return Icons.business_center_outlined;
      default:
        return Icons.apps_outlined;
    }
  }

  void _abrirFormulario(int index) {
    final v = _viagens[index];
    _destinoController.text = v.destino;
    _inicioController.text = v.dataInicio;
    _fimController.text = v.dataFim;
    _orcamentoController.text = v.orcamento;
    _anotacoesController.text = v.anotacoes;
    setState(() => _expandidoIndex = index);
  }

  void _fecharFormulario() => setState(() => _expandidoIndex = null);

  void _salvarViagem(int index) async {
    final docId = _viagens[index].id;
    if (docId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('viagens')
            .doc(docId)
            .update({
              'destino': _destinoController.text.trim(),
              'dataInicio': _inicioController.text.trim(),
              'dataFim': _fimController.text.trim(),
              'orcamento': _orcamentoController.text.trim(),
              'anotacoes': _anotacoesController.text.trim(),
            });
        setState(() => _expandidoIndex = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Viagem salva com sucesso!'),
            backgroundColor: Color(0xFF1E83DB),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar viagem: $e')));
      }
    }
  }

  void _excluirViagem(int index) async {
    final docId = _viagens[index].id;
    if (docId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('viagens')
            .doc(docId)
            .delete();
        setState(() => _expandidoIndex = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Viagem excluída com sucesso!'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir viagem: $e')));
      }
    }
  }

  Future<void> _selecionarData(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1E83DB)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void _abrirDuplicar(Viagem viagem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DuplicarViagemPage(
          viagem: viagem,
          onDuplicar: (novaViagem) async {
            try {
              await FirebaseFirestore.instance.collection('viagens').add({
                'destino': novaViagem.destino,
                'imagemUrl': novaViagem.imagemUrl,
                'dataInicio': novaViagem.dataInicio,
                'dataFim': novaViagem.dataFim,
                'orcamento': novaViagem.orcamento,
                'anotacoes': novaViagem.anotacoes,
                'tipo': novaViagem.tipo,
                'confirmada': true,
                'usuarioId': FirebaseAuth.instance.currentUser?.uid ?? '',
                'criado_por': FirebaseAuth.instance.currentUser?.email ?? '',
                'criado_em': FieldValue.serverTimestamp(),
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao duplicar viagem: $e')),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E83DB)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomePage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
        ),
        title: Text(
          'Suas Viagens',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtrar por',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(_filtros.length, (i) {
                    final sel = _filtroBotao == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _filtroBotao = i;
                            _aplicarFiltros();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFFE8F4FD)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel
                                  ? const Color(0xFF1E83DB)
                                  : Colors.grey.shade300,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            _filtros[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: sel
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: sel
                                  ? const Color(0xFF1E83DB)
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),

                if (_filtroBotao == 0) ...[
                  Text(
                    'Período',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _campoPeriodo(_periodoInicio, () async {
                          final ctrl = TextEditingController(
                            text: _periodoInicio,
                          );
                          await _selecionarData(ctrl);
                          if (ctrl.text != _periodoInicio)
                            setState(() => _periodoInicio = ctrl.text);
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'até',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _campoPeriodo(_periodoFim, () async {
                          final ctrl = TextEditingController(text: _periodoFim);
                          await _selecionarData(ctrl);
                          if (ctrl.text != _periodoFim)
                            setState(() => _periodoFim = ctrl.text);
                        }),
                      ),
                    ],
                  ),
                ],

                if (_filtroBotao == 1) ...[
                  Text(
                    'Pesquisar Destino',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _buscaDestinoController,
                    onChanged: (value) => _aplicarFiltros(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: _inputDeco(
                      hint: 'Digite o destino...',
                      icon: Icons.search,
                    ),
                  ),
                ],

                if (_filtroBotao == 2) ...[
                  Text(
                    'Selecione o Tipo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getIconForTipo(_tipoSelecionado),
                          color: const Color(0xFF0284C7),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _tipoSelecionado,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              items: _tiposDisponiveis.map((tipo) {
                                return DropdownMenuItem(
                                  value: tipo,
                                  child: Text(tipo),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _tipoSelecionado = newValue;
                                  _aplicarFiltros();
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
              ],
            ),
          ),

          Expanded(
            child: _viagens.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma viagem encontrada.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _viagens.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _viagens.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 12),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HistoricoViagensPage(),
                              ),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Dashboard de Gastos',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      final expandido = _expandidoIndex == index;
                      return AnimatedSize(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: expandido
                              ? _buildFormulario(index)
                              : _buildCardViagem(_viagens[index], index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(currentIndex: 3),
    );
  }

  Widget _buildCardViagem(Viagem viagem, int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _abrirFormulario(index),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                viagem.imagemUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viagem.destino,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_diaMs(viagem.dataInicio)} à ${_diaMs(viagem.dataFim)} ${_ano(viagem.dataFim)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _abrirDuplicar(viagem),
              child: Container(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.copy_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulario(int index) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _viagens[index].imagemUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _viagens[index].destino,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: _fecharFormulario,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _label('DESTINO'),
          _campoTexto(
            controller: _destinoController,
            hintText: 'Ex: Paris',
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_label('INÍCIO'), _campoData(_inicioController)],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_label('FIM'), _campoData(_fimController)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _label('ORÇAMENTO PREVISTO'),
          _campoTexto(
            controller: _orcamentoController,
            hintText: '0,00',
            prefixIcon: Icons.attach_money,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _label('ANOTAÇÕES'),
          TextField(
            controller: _anotacoesController,
            maxLines: 3,
            decoration: _inputDeco(
              hint: 'Adicione notas sobre sua viagem...',
              icon: null,
            ).copyWith(contentPadding: const EdgeInsets.all(14)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _excluirViagem(index),
                    child: const Text(
                      'Excluir',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1BCE8A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _salvarViagem(index),
                    child: const Text(
                      'Editar Viagem',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _campoPeriodo(String texto, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          texto,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
      ),
    );
  }

  Widget _label(String texto) => Padding(
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

  InputDecoration _inputDeco({required String hint, IconData? icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.grey.shade400, size: 20)
            : null,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
          borderSide: const BorderSide(color: Color(0xFF1E83DB), width: 1.5),
        ),
      );

  Widget _campoTexto({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: const TextStyle(fontSize: 14),
    decoration: _inputDeco(hint: hintText, icon: prefixIcon),
  );

  Widget _campoData(TextEditingController controller) => TextField(
    controller: controller,
    readOnly: true,
    onTap: () => _selecionarData(controller),
    style: const TextStyle(fontSize: 13),
    decoration: _inputDeco(
      hint: 'dd/mm/aaaa',
      icon: Icons.calendar_today_outlined,
    ),
  );

  String _diaMs(String data) {
    if (data.length < 5) return data;
    final p = data.split('/');
    if (p.length < 2) return data;
    const m = [
      '',
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    final mes = int.tryParse(p[1]) ?? 0;
    return '${p[0]} ${mes >= 1 && mes <= 12 ? m[mes] : p[1]}';
  }

  String _ano(String data) {
    final p = data.split('/');
    return p.length >= 3 ? p[2] : '';
  }
}

class DuplicarViagemPage extends StatefulWidget {
  final Viagem viagem;
  final void Function(Viagem novaViagem) onDuplicar;

  const DuplicarViagemPage({
    super.key,
    required this.viagem,
    required this.onDuplicar,
  });

  @override
  State<DuplicarViagemPage> createState() => _DuplicarViagemPageState();
}

class _DuplicarViagemPageState extends State<DuplicarViagemPage> {
  late TextEditingController _nomeController;
  late TextEditingController _dataController;
  bool _duplicarRoteiro = true;
  bool _duplicarLocais = true;
  bool _duplicarCompromissos = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: '${widget.viagem.destino} — Copia',
    );
    _dataController = TextEditingController(text: '20/03/2026');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  int _calcularDias() {
    try {
      final pi = widget.viagem.dataInicio.split('/');
      final pf = widget.viagem.dataFim.split('/');
      final inicio = DateTime(
        int.parse(pi[2]),
        int.parse(pi[1]),
        int.parse(pi[0]),
      );
      final fim = DateTime(
        int.parse(pf[2]),
        int.parse(pf[1]),
        int.parse(pf[0]),
      );
      return fim.difference(inicio).inDays + 1;
    } catch (_) {
      return 0;
    }
  }

  String _periodoCard() {
    try {
      final pi = widget.viagem.dataInicio.split('/');
      final pf = widget.viagem.dataFim.split('/');
      const m = [
        '',
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez',
      ];
      final mi = int.tryParse(pi[1]) ?? 0;
      final mf = int.tryParse(pf[1]) ?? 0;
      final dias = _calcularDias();
      return '${pi[0]} ${m[mi]} a ${pf[0]} ${m[mf]} • $dias dias';
    } catch (_) {
      return widget.viagem.periodo;
    }
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1BCE8A)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dataController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _criarCopia() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final origemId = widget.viagem.id;

    // Calcula dataFim da cópia mantendo a mesma duração da original
    DateTime? novaInicio;
    DateTime? novaFim;
    try {
      final p = _dataController.text.split('/');
      novaInicio = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      final pi = widget.viagem.dataInicio.split('/');
      final pf = widget.viagem.dataFim.split('/');
      final inicioOrig = DateTime(
        int.parse(pi[2]),
        int.parse(pi[1]),
        int.parse(pi[0]),
      );
      final fimOrig = DateTime(
        int.parse(pf[2]),
        int.parse(pf[1]),
        int.parse(pf[0]),
      );
      final duracao = fimOrig.difference(inicioOrig);
      novaFim = novaInicio.add(duracao);
    } catch (_) {
      novaInicio = DateTime.now();
      novaFim = DateTime.now();
    }

    final db = FirebaseFirestore.instance;

    try {
      // 1. Cria o documento raiz da nova viagem
      final novoDocRef = await db.collection('viagens').add({
        'destino': nome,
        'imagemUrl': widget.viagem.imagemUrl,
        'dataInicio': Timestamp.fromDate(novaInicio),
        'dataFim': Timestamp.fromDate(novaFim),
        'orcamento': widget.viagem.orcamento,
        'anotacoes': widget.viagem.anotacoes,
        'tipo': widget.viagem.tipo,
        'confirmada': true,
        'usuarioId': uid,
        'criado_por': email,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      // 2. Copia subcoleções conforme checkboxes
      if (origemId != null) {
        final origemRef = db.collection('viagens').doc(origemId);

        if (_duplicarCompromissos) {
          final snap = await origemRef.collection('compromissos').get();
          for (final doc in snap.docs) {
            await novoDocRef.collection('compromissos').add(doc.data());
          }
        }

        if (_duplicarRoteiro) {
          final roteiroSnap = await origemRef.collection('roteiro').get();
          for (final roteiroDoc in roteiroSnap.docs) {
            final novoRoteiroRef = await novoDocRef
                .collection('roteiro')
                .add(roteiroDoc.data());

            if (_duplicarLocais) {
              final locaisSnap = await roteiroDoc.reference
                  .collection('locais')
                  .get();
              for (final local in locaisSnap.docs) {
                await novoRoteiroRef.collection('locais').add(local.data());
              }
            }
          }
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cópia "$nome" criada com sucesso!'),
          backgroundColor: const Color(0xFF1BCE8A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao duplicar viagem: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Duplicar Viagem',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1BCE8A), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.viagem.imagemUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _periodoCard(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.copy_outlined,
                    color: Color(0xFF1BCE8A),
                    size: 22,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _label('Nome da cópia'),
            _campo(controller: _nomeController, hint: 'Ex: Paris — Copia'),
            const SizedBox(height: 16),

            _label('Nova data de início'),
            GestureDetector(
              onTap: _selecionarData,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.grey.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _dataController.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'O que duplicar?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            _checkItem(
              'Roteiro de dias',
              _duplicarRoteiro,
              (v) => setState(() => _duplicarRoteiro = v!),
            ),
            _checkItem(
              'Locais de visita',
              _duplicarLocais,
              (v) => setState(() => _duplicarLocais = v!),
            ),
            _checkItem(
              'Compromissos',
              _duplicarCompromissos,
              (v) => setState(() => _duplicarCompromissos = v!),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async => await _criarCopia(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BCE8A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Criar Cópia da Viagem',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String texto) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      texto,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade600,
      ),
    ),
  );

  Widget _campo({
    required TextEditingController controller,
    required String hint,
  }) => TextField(
    controller: controller,
    style: TextStyle(
      fontSize: 14,
      color: Theme.of(context).colorScheme.onSurface,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        borderSide: const BorderSide(color: Color(0xFF1BCE8A), width: 1.5),
      ),
    ),
  );

  Widget _checkItem(String label, bool valor, void Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Checkbox(
            value: valor,
            onChanged: onChanged,
            activeColor: const Color(0xFF1BCE8A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(
              color: valor ? const Color(0xFF1BCE8A) : Colors.grey.shade400,
              width: 1.5,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: valor ? Colors.black87 : Colors.grey.shade500,
              fontWeight: valor ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
