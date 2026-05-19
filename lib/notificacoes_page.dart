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
final List<Viagem> viagensMock = [
  Viagem(
    destino: 'Paris',
    dataInicio: '10/06/2026',
    dataFim: '18/06/2026',
    orcamento: '5.000',
    anotacoes: 'Visitar o museu local, jantar no restaurante indicado...',
    imagemUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
  ),
  Viagem(
    destino: 'Paris',
    dataInicio: '10/06/2026',
    dataFim: '18/06/2026',
    orcamento: '3.250',
    anotacoes: 'Segunda viagem a Paris, foco em museus.',
    imagemUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
  ),
  Viagem(
    destino: 'Paris',
    dataInicio: '10/06/2026',
    dataFim: '18/06/2026',
    orcamento: '6.750',
    anotacoes: 'Terceira viagem, passeio de barco no Sena.',
    imagemUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
  ),
];

// ─────────────────────────────────────────────
// PÁGINA PRINCIPAL
// ─────────────────────────────────────────────
class ViagensPage extends StatefulWidget {
  const ViagensPage({super.key});

  @override
  State<ViagensPage> createState() => _ViagensPageState();
}

class _ViagensPageState extends State<ViagensPage> {
  final List<Viagem> _viagens = List.from(viagensMock);
  int? _expandidoIndex; // qual card está expandido com formulário

  // Controllers do formulário
  final _destinoController = TextEditingController();
  final _inicioController = TextEditingController();
  final _fimController = TextEditingController();
  final _orcamentoController = TextEditingController();
  final _anotacoesController = TextEditingController();

  void _abrirFormulario(int index) {
    final v = _viagens[index];
    _destinoController.text = v.destino;
    _inicioController.text = v.dataInicio;
    _fimController.text = v.dataFim;
    _orcamentoController.text = v.orcamento;
    _anotacoesController.text = v.anotacoes;
    setState(() => _expandidoIndex = index);
  }

  void _fecharFormulario() {
    setState(() => _expandidoIndex = null);
  }

  void _salvarViagem(int index) {
    setState(() {
      _viagens[index].destino = _destinoController.text;
      _viagens[index].dataInicio = _inicioController.text;
      _viagens[index].dataFim = _fimController.text;
      _viagens[index].orcamento = _orcamentoController.text;
      _viagens[index].anotacoes = _anotacoesController.text;
      _expandidoIndex = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Viagem salva com sucesso!'),
        backgroundColor: Color(0xFF1E83DB),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  @override
  void dispose() {
    _destinoController.dispose();
    _inicioController.dispose();
    _fimController.dispose();
    _orcamentoController.dispose();
    _anotacoesController.dispose();
    super.dispose();
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
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _viagens.length,
        itemBuilder: (context, index) {
          final viagem = _viagens[index];
          final expandido = _expandidoIndex == index;

          return AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: expandido
                  ? _buildFormulario(index)
                  : _buildCardViagem(viagem, index),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Card compacto ──────────────────────────────────
  Widget _buildCardViagem(Viagem viagem, int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${viagem.dataInicio.substring(0, 5)} à ${viagem.dataFim.substring(0, 5)} ${viagem.dataFim.substring(6)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
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

  // ── Formulário expandido ───────────────────────────
  Widget _buildFormulario(int index) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com foto
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

          // Campo Destino
          _label('DESTINO'),
          _campoTexto(
            controller: _destinoController,
            hintText: 'Ex: Paris',
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),

          // Datas
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('INÍCIO'),
                    _campoData(_inicioController),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('FIM'),
                    _campoData(_fimController),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Orçamento
          _label('ORÇAMENTO PREVISTO'),
          _campoTexto(
            controller: _orcamentoController,
            hintText: '0,00',
            prefixIcon: Icons.attach_money,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          // Anotações
          _label('ANOTAÇÕES'),
          TextField(
            controller: _anotacoesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Adicione notas sobre sua viagem...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              contentPadding: const EdgeInsets.all(14),
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
                borderSide: const BorderSide(color: Color(0xFF1E83DB)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Botão salvar
          SizedBox(
            width: double.infinity,
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
        ],
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

  Widget _campoTexto({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: Colors.grey.shade400, size: 20),
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
            borderSide: const BorderSide(color: Color(0xFF1E83DB)),
          ),
        ),
      );

  Widget _campoData(TextEditingController controller) => TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _selecionarData(controller),
        decoration: InputDecoration(
          hintText: 'dd/mm/aaaa',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(Icons.calendar_today_outlined,
              color: Colors.grey.shade400, size: 18),
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
            borderSide: const BorderSide(color: Color(0xFF1E83DB)),
          ),
        ),
      );

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 3,
      selectedItemColor: const Color(0xFF1E83DB),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Agenda'),
        BottomNavigationBarItem(icon: Icon(Icons.flight_outlined), label: 'Viagens'),
      ],
    );
  }
}