import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'viagem_model.dart';
import 'viagens_page.dart';

class HistoricoViagensPage extends StatefulWidget {
  const HistoricoViagensPage({super.key});

  @override
  State<HistoricoViagensPage> createState() => _HistoricoViagensPageState();
}

class _HistoricoViagensPageState extends State<HistoricoViagensPage> {
  List<Viagem> _viagens = [];
  StreamSubscription<QuerySnapshot>? _subscription;
  String _anoSelecionado = '2026';
  final List<String> _anos = ['2024', '2025', '2026'];

  @override
  void initState() {
    super.initState();
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    _subscription = FirebaseFirestore.instance
        .collection('viagens')
        .where('criado_por', isEqualTo: email)
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;
          setState(() {
            _viagens = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Viagem(
                id: doc.id,
                destino: data['destino'] ?? '',
                imagemUrl:
                    data['imagemUrl'] ??
                    'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
                dataInicio: data['dataInicio'] ?? '',
                dataFim: data['dataFim'] ?? '',
                orcamento: data['orcamento'] ?? '',
                anotacoes: data['anotacoes'] ?? '',
                tipo: data['tipo'] ?? 'Lazer',
                confirmada: data['confirmada'] ?? true,
              );
            }).toList();
          });
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  List<Viagem> get _viagensFiltradas {
    return _viagens.where((v) {
      if (v.dataInicio.isEmpty) return false;
      final parts = v.dataInicio.split('/');
      if (parts.length == 3) {
        return parts[2] == _anoSelecionado;
      }
      return false;
    }).toList();
  }

  double get _totalInvestido => _viagensFiltradas.fold(
    0,
    (soma, v) =>
        soma +
        (double.tryParse(
              v.orcamento.replaceAll('.', '').replaceAll(',', '.'),
            ) ??
            0),
  );

  int get _totalViagens => _viagensFiltradas.length;

  String _formatarReal(double valor) {
    final s = valor.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return 'R\$ ${buffer.toString()}';
  }

  void _verDetalhes(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ViagensPage()),
    );
  }

  Future<void> _abrirCalendario() async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E83DB),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataSelecionada != null) {
      setState(() {
        _anoSelecionado = dataSelecionada.year.toString();
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E83DB)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/logo_completa.png',
          height: 55,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Travel',
                  style: TextStyle(
                    color: Color(0xFF101828),
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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico de Gastos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
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
                            horizontal: 14,
                            vertical: 6,
                          ),
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
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF1E83DB),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: _abrirCalendario,
                        child: Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.grey.shade400,
                          size: 20,
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
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                      height: 1.1,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'Viagens',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
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
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'INVESTIMENTO TOTAL',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatarReal(_totalInvestido),
                              style: const TextStyle(
                                fontSize: 26,
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gastos por Viagem',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ViagensPage()),
                  ),
                  child: const Text(
                    'Ver todas',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1E83DB),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _viagensFiltradas.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text(
                        'Nenhuma viagem registrada neste ano.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: List.generate(
                      _viagensFiltradas.length,
                      (index) =>
                          _buildCardGasto(_viagensFiltradas[index], index),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardGasto(Viagem viagem, int index) {
    final valor =
        double.tryParse(
          viagem.orcamento.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              viagem.imagemUrl,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
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
                Text(
                  viagem.destino,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatarReal(valor),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _mesAno(viagem.dataInicio),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _verDetalhes(index),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1BCE8A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Ver Detalhes'),
          ),
        ],
      ),
    );
  }
}
