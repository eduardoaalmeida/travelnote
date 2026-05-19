import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// MODELO
// ─────────────────────────────────────────────
class Viagem {
  String destino;
  String dataInicio;
  String dataFim;
  String orcamento;
  String anotacoes;
  String imagemUrl;

  Viagem({
    required this.destino,
    required this.dataInicio,
    required this.dataFim,
    required this.orcamento,
    required this.anotacoes,
    required this.imagemUrl,
  });
}

// ─────────────────────────────────────────────
// DADOS MOCKADOS
// ─────────────────────────────────────────────
final List<Viagem> _viagensMock = [
  Viagem(
    destino: 'Paris',
    dataInicio: '10/06/2026',
    dataFim: '18/06/2026',
    orcamento: '5.000',
    anotacoes: 'Visitar o museu local, jantar no restaurante indicado...',
    imagemUrl:
        'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
  ),
  Viagem(
    destino: 'Paris',
    dataInicio: '10/06/2026',
    dataFim: '18/06/2026',
    orcamento: '3.250',
    anotacoes: 'Segunda viagem a Paris, foco em museus.',
    imagemUrl:
        'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
  ),
  Viagem(
    destino: 'Paris',
    dataInicio: '10/06/2026',
    dataFim: '18/06/2026',
    orcamento: '6.750',
    anotacoes: 'Terceira viagem, passeio de barco no Sena.',
    imagemUrl:
        'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
  ),
];

class ViagensPage extends StatefulWidget {
  const ViagensPage({super.key});

  @override
  State<ViagensPage> createState() => _ViagensPageState();
}

class _ViagensPageState extends State<ViagensPage> {
  final List<Viagem> _viagens = List.from(_viagensMock);
  int _expandidoIndex = -1;

  final _destinoCtrl = TextEditingController();
  final _inicioCtrl = TextEditingController();
  final _fimCtrl = TextEditingController();
  final _orcamentoCtrl = TextEditingController();
  final _anotacoesCtrl = TextEditingController();

  @override
  void dispose() {
    _destinoCtrl.dispose();
    _inicioCtrl.dispose();
    _fimCtrl.dispose();
    _orcamentoCtrl.dispose();
    _anotacoesCtrl.dispose();
    super.dispose();
  }

  void _abrirFormulario(int index) {
    final v = _viagens[index];
    _destinoCtrl.text = v.destino;
    _inicioCtrl.text = v.dataInicio;
    _fimCtrl.text = v.dataFim;
    _orcamentoCtrl.text = v.orcamento;
    _anotacoesCtrl.text = v.anotacoes;
    setState(() => _expandidoIndex = index);
  }

  void _fecharFormulario() => setState(() => _expandidoIndex = -1);

  void _salvarViagem(int index) {
    if (_destinoCtrl.text.isEmpty) return;
    setState(() {
      _viagens[index]
        ..destino = _destinoCtrl.text
        ..dataInicio = _inicioCtrl.text
        ..dataFim = _fimCtrl.text
        ..orcamento = _orcamentoCtrl.text
        ..anotacoes = _anotacoesCtrl.text;
      _expandidoIndex = -1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Viagem atualizada com sucesso!'),
        backgroundColor: Color(0xFF1E83DB),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selecionarData(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1E83DB)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
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
        title: const Text(
          'Suas Viagens',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _viagens.length,
        itemBuilder: (context, index) {
          final expandido = _expandidoIndex == index;
          return AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
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
    );
  }

  Widget _buildCardViagem(Viagem v, int index) {
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
                v.imagemUrl,
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
                    v.destino,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_diaMs(v.dataInicio)} à ${_diaMs(v.dataFim)} ${_ano(v.dataFim)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.more_horiz, color: Colors.grey.shade400),
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
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
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
                      fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: _fecharFormulario,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 14),
          _label('DESTINO'),
          _campo(ctrl: _destinoCtrl, hint: 'Ex: Paris', icon: Icons.location_on_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_label('INÍCIO'), _campoData(_inicioCtrl)],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_label('FIM'), _campoData(_fimCtrl)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _label('ORÇAMENTO PREVISTO'),
          _campo(
            ctrl: _orcamentoCtrl,
            hint: '0,00',
            icon: Icons.attach_money,
            tipo: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _label('ANOTAÇÕES'),
          TextField(
            controller: _anotacoesCtrl,
            maxLines: 3,
            style: const TextStyle(fontSize: 14),
            decoration: _inputDeco(hint: 'Adicione notas sobre sua viagem...')
                .copyWith(prefixIcon: null, contentPadding: const EdgeInsets.all(14)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1BCE8A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _salvarViagem(index),
              child: const Text(
                'Editar Viagem',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────
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

  Widget _campo({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType tipo = TextInputType.text,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: tipo,
        style: const TextStyle(fontSize: 14),
        decoration: _inputDeco(hint: hint, icon: icon),
      );

  Widget _campoData(TextEditingController ctrl) => TextField(
        controller: ctrl,
        readOnly: true,
        onTap: () => _selecionarData(ctrl),
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
    const m = ['','Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
    final mes = int.tryParse(p[1]) ?? 0;
    return '${p[0]} ${mes >= 1 && mes <= 12 ? m[mes] : p[1]}';
  }

  String _ano(String data) {
    final p = data.split('/');
    return p.length >= 3 ? p[2] : '';
  }
}