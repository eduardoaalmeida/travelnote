import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'viagem_model.dart';
import 'gasto_model.dart';
import 'notification_service.dart';
import 'navbar.dart';
import 'package:flutter/services.dart';

class HistoricoViagensPage extends StatefulWidget {
  final String? viagemIdInicial;

  const HistoricoViagensPage({super.key, this.viagemIdInicial});

  @override
  State<HistoricoViagensPage> createState() => _HistoricoViagensPageState();
}

class _HistoricoViagensPageState extends State<HistoricoViagensPage> {
  List<Viagem> _viagens = [];
  Map<String, List<Gasto>> _gastosPorViagem = {};
  StreamSubscription<QuerySnapshot>? _subViagens;
  StreamSubscription<QuerySnapshot>? _subGastos;
  String _anoSelecionado = DateTime.now().year.toString();
  final List<String> _anos = ['2024', '2025', '2026'];

  // FIX 3: Estados de carregamento separados por stream.
  bool _carregandoViagens = true;
  bool _carregandoGastos = true;

  /// Exibe o loading spinner apenas enquanto AMBOS os streams ainda não entregaram o primeiro snapshot.
  bool get _carregando => _carregandoViagens && _carregandoGastos;

  bool _viagemInicialAberta = false;

  @override
  void initState() {
    super.initState();
    _iniciarStreams();
  }

  void _iniciarStreams() {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    // ── Stream das viagens ──────────────────────────────────────────────────
    _subViagens = FirebaseFirestore.instance
        .collection('viagens')
        .where('criado_por', isEqualTo: email)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      setState(() {
        _viagens = snap.docs.map((doc) {
          final data = doc.data();
          return Viagem(
            id: doc.id,
            destino: data['destino'] ?? '',
            imagemUrl: data['imagemUrl'] ??
                'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
            dataInicio: _formatarCampoData(data['dataInicio']),
            dataFim: _formatarCampoData(data['dataFim']),
            orcamento: _limparOrcamento(data['orcamento'] ?? ''),
            anotacoes: data['anotacoes'] ?? '',
            tipo: data['tipo'] ?? 'Lazer',
            confirmada: data['confirmada'] ?? true,
          );
        }).toList();
        _carregandoViagens = false;

        // Lógica de redirecionamento automático para viagemIdInicial
        if (widget.viagemIdInicial != null && !_viagemInicialAberta) {
          final index =
              _viagens.indexWhere((v) => v.id == widget.viagemIdInicial);
          if (index != -1) {
            final viagemAlvo = _viagens[index];
            _viagemInicialAberta = true;
            if (viagemAlvo.dataInicio.isNotEmpty) {
              final parts = viagemAlvo.dataInicio.split('/');
              if (parts.length == 3) {
                _anoSelecionado = parts[2];
              }
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _abrirDetalhesViagem(viagemAlvo);
            });
          }
        }
      });
    });

    // ── Stream de gastos ────────────────────────────────────────────────────
   _subGastos = FirebaseFirestore.instance
    .collection('gastos')
    .where('criado_por', isEqualTo: email) // <-- Filtro em um campo
    .orderBy('data', descending: true)     // <-- Ordenação em OUTRO campo
    .snapshots()
        .listen((snap) {
      if (!mounted) return;

      final mapa = <String, List<Gasto>>{};
      for (final doc in snap.docs) {
        final gasto = Gasto.fromDoc(doc);
        mapa.putIfAbsent(gasto.viagemId, () => []).add(gasto);
      }

      // FIX 3 (cont.): Atualiza o mapa de gastos e marca o stream como pronto.
      setState(() {
        if (mapa.isNotEmpty || _carregandoGastos) {
          _gastosPorViagem = mapa;
        }
        _carregandoGastos = false;
      });

      NotificacaoService.verificarOrcamentosExcedidos();
    });
  }

  @override
  void dispose() {
    _subViagens?.cancel();
    _subGastos?.cancel();
    super.dispose();
  }

  String _formatarCampoData(dynamic valor) {
    if (valor == null) return '';
    if (valor is String) return valor;
    if (valor is Timestamp) {
      final d = valor.toDate();
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }
    return '';
  }

  String _limparOrcamento(dynamic valor) {
    if (valor == null) return '';
    if (valor is num) return valor.toStringAsFixed(2).replaceAll('.', ',');
    return valor.toString();
  }

  List<Viagem> get _viagensFiltradas {
    return _viagens.where((v) {
      if (v.dataInicio.isEmpty) return false;
      final parts = v.dataInicio.split('/');
      return parts.length == 3 && parts[2] == _anoSelecionado;
    }).toList();
  }

  double _totalGastosViagem(String? viagemId) {
    if (viagemId == null) return 0;
    return (_gastosPorViagem[viagemId] ?? [])
        .fold(0, (soma, g) => soma + g.valor);
  }

  double _orcamentoViagem(Viagem v) {
    return double.tryParse(
          v.orcamento.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;
  }

  double get _totalInvestido =>
      _viagensFiltradas.fold(0, (s, v) => s + _totalGastosViagem(v.id));

  int get _totalViagens => _viagensFiltradas.length;

  String _formatarReal(double valor) {
    final s = valor.toStringAsFixed(2);
    final partes = s.split('.');
    final inteiro = partes[0];
    final centavos = partes[1];
    final buffer = StringBuffer();
    for (int i = 0; i < inteiro.length; i++) {
      if (i > 0 && (inteiro.length - i) % 3 == 0) buffer.write('.');
      buffer.write(inteiro[i]);
    }
    return 'R\$ ${buffer.toString()},$centavos';
  }

  String _mesAno(String data) {
    if (data.length < 10) return data;
    final p = data.split('/');
    if (p.length < 3) return data;
    const meses = [
      '',
      'JANEIRO',
      'FEVEREIRO',
      'MARÇO',
      'ABRIL',
      'MAIO',
      'JUNHO',
      'JULHO',
      'AGOSTO',
      'SETEMBRO',
      'OUTUBRO',
      'NOVEMBRO',
      'DEZEMBRO',
    ];
    final mes = int.tryParse(p[1]) ?? 0;
    return '${mes >= 1 && mes <= 12 ? meses[mes] : p[1]} ${p[2]}';
  }

  void _mostrarSeletorAno() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selecionar Ano',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ..._anos.map(
              (ano) => ListTile(
                title: Text(ano),
                trailing: ano == _anoSelecionado
                    ? const Icon(Icons.check, color: Color(0xFF1E83DB))
                    : null,
                onTap: () {
                  setState(() => _anoSelecionado = ano);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirDetalhesViagem(Viagem viagem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetalhesGastosSheet(
        viagem: viagem,
        gastos: _gastosPorViagem[viagem.id] ?? [],
        orcamento: _orcamentoViagem(viagem),
        totalGasto: _totalGastosViagem(viagem.id),
        formatarReal: _formatarReal,
        onAdicionarGasto: () => _abrirFormGasto(viagem),
      ),
    );
  }

  void _abrirFormGasto(Viagem viagem) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FormGastoSheet(
        viagem: viagem,
        onSalvar: (gasto) => _salvarGasto(gasto),
      ),
    );
  }

 Future<void> _salvarGasto(Gasto gasto) async {
    try {
      await FirebaseFirestore.instance.collection('gastos').add(gasto.toMap());
      
      // CORREÇÃO: Força a execução imediata da checagem de orçamento logo após salvar
      await NotificacaoService.verificarOrcamentosExcedidos();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gasto registrado com sucesso!'),
            backgroundColor: Color(0xFF1BCE8A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar gasto: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E83DB)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 3),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Histórico de Gastos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Card de resumo ─────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: _mostrarSeletorAno,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F4FD),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Ano $_anoSelecionado',
                                      style: const TextStyle(
                                        color: Color(0xFF1E83DB),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.keyboard_arrow_down,
                                        color: Color(0xFF1E83DB), size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TOTAL DE VIAGENS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '$_totalViagens\n',
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w800,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            height: 1.1,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Viagens',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 60,
                              color: Colors.grey.shade200,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TOTAL GASTO',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _carregandoGastos
                                      ? Container(
                                          height: 22,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                        )
                                      : Text(
                                          _formatarReal(_totalInvestido),
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF1E83DB),
                                            height: 1.1,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Gastos por Viagem',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _viagensFiltradas.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'Nenhuma viagem registrada neste ano.',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                      : Column(
                          children: _viagensFiltradas
                              .map((v) => _buildCardGasto(v))
                              .toList(),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildCardGasto(Viagem viagem) {
    final totalGasto = _totalGastosViagem(viagem.id);
    final orcamento = _orcamentoViagem(viagem);
    final excedeu = orcamento > 0 && totalGasto > orcamento;
    final progresso =
        orcamento > 0 ? (totalGasto / orcamento).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: excedeu
            ? Border.all(color: const Color(0xFFFFCDD2), width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  viagem.imagemUrl,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 68,
                    height: 68,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            viagem.destino,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (excedeu)
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFE53935), size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _carregandoGastos
                        ? Container(
                            height: 16,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : Text(
                            _formatarReal(totalGasto),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: excedeu
                                  ? const Color(0xFFE53935)
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                    if (orcamento > 0)
                      Text(
                        'de ${_formatarReal(orcamento)} orçado',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      _mesAno(viagem.dataInicio),
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.3),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _abrirDetalhesViagem(viagem),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BCE8A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                child: const Text('Ver Detalhes'),
              ),
            ],
          ),
          if (orcamento > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progresso,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  excedeu
                      ? const Color(0xFFE53935)
                      : const Color(0xFF1BCE8A),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Sheet de detalhes dos gastos ───────────────────────────────────────────

class _DetalhesGastosSheet extends StatelessWidget {
  final Viagem viagem;
  final List<Gasto> gastos;
  final double orcamento;
  final double totalGasto;
  final String Function(double) formatarReal;
  final VoidCallback onAdicionarGasto;

  const _DetalhesGastosSheet({
    required this.viagem,
    required this.gastos,
    required this.orcamento,
    required this.totalGasto,
    required this.formatarReal,
    required this.onAdicionarGasto,
  });

  @override
  Widget build(BuildContext context) {
    final excedeu = orcamento > 0 && totalGasto > orcamento;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    viagem.destino,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onAdicionarGasto,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Adicionar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1BCE8A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Gasto: ${formatarReal(totalGasto)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: excedeu
                        ? const Color(0xFFE53935)
                        : const Color(0xFF1BCE8A),
                  ),
                ),
                if (orcamento > 0) ...[
                  Text(
                    '  /  Orçado: ${formatarReal(orcamento)}',
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Expanded(
              child: gastos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          const Text(
                            'Nenhum gasto registrado ainda.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: controller,
                      itemCount: gastos.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final g = gastos[i];
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE8F4FD),
                            child: Icon(
                              _iconeCategoria(g.categoria),
                              color: const Color(0xFF1E83DB),
                              size: 18,
                            ),
                          ),
                          title: Text(
                            g.descricao,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${g.categoria} · ${_formatarData(g.data)}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                          trailing: Text(
                            formatarReal(g.valor),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E83DB),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconeCategoria(String cat) {
    switch (cat) {
      case 'Transporte':
        return Icons.directions_car_outlined;
      case 'Hospedagem':
        return Icons.hotel_outlined;
      case 'Alimentação':
        return Icons.restaurant_outlined;
      case 'Passeios':
        return Icons.map_outlined;
      case 'Compras':
        return Icons.shopping_bag_outlined;
      case 'Saúde':
        return Icons.local_hospital_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ─── Sheet de formulário para adicionar gasto ────────────────────────────────

class _FormGastoSheet extends StatefulWidget {
  final Viagem viagem;
  final void Function(Gasto) onSalvar;

  const _FormGastoSheet({required this.viagem, required this.onSalvar});

  @override
  State<_FormGastoSheet> createState() => _FormGastoSheetState();
}

class _FormGastoSheetState extends State<_FormGastoSheet> {
  final _descricaoCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  String _categoria = 'Outros';
  bool _salvando = false;

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    final descricao = _descricaoCtrl.text.trim();
    final valorStr = _valorCtrl.text
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final valor = double.tryParse(valorStr) ?? 0;

    if (descricao.isEmpty || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha descrição e valor corretamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    widget.onSalvar(
      Gasto(
        viagemId: widget.viagem.id ?? '',
        descricao: descricao,
        valor: valor,
        categoria: _categoria,
        data: DateTime.now(),
        criadoPor: email,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Adicionar Gasto — ${widget.viagem.destino}',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _label('DESCRIÇÃO'),
            _campo(
              controller: _descricaoCtrl,
              hint: 'Ex: Jantar no restaurante',
              icon: Icons.description_outlined,
            ),
            const SizedBox(height: 12),
            _label('VALOR (R\$)'),
            TextField(
              controller: _valorCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final nums =
                      newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
                  if (nums.isEmpty) return const TextEditingValue(text: '');
                  final inteiro = int.parse(nums);
                  final reais = inteiro ~/ 100;
                  final centavos =
                      (inteiro % 100).toString().padLeft(2, '0');
                  final reaisStr = reais.toString();
                  final buf = StringBuffer();
                  for (int i = 0; i < reaisStr.length; i++) {
                    if (i > 0 && (reaisStr.length - i) % 3 == 0) {
                      buf.write('.');
                    }
                    buf.write(reaisStr[i]);
                  }
                  final formatted = '${buf.toString()},$centavos';
                  return TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                }),
              ],
              decoration: InputDecoration(
                hintText: '0,00',
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.attach_money,
                    color: Colors.grey.shade400, size: 20),
                filled: true,
                fillColor: const Color(0xFFF7F8FA),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
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
                  borderSide: const BorderSide(
                      color: Color(0xFF1BCE8A), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _label('CATEGORIA'),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _categoria,
                  items: Gasto.categorias
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _categoria = v ?? 'Outros'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BCE8A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Salvar Gasto',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
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

  Widget _campo({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType tipo = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: tipo,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon:
              Icon(icon, color: Colors.grey.shade400, size: 20),
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
            borderSide:
                const BorderSide(color: Color(0xFF1BCE8A), width: 1.5),
          ),
        ),
      );
}