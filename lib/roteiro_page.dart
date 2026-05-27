import 'package:flutter/material.dart';
import 'navbar.dart';

// ── Modelo ────────────────────────────────────────────────────────────────────
class LocalRoteiro {
  String numero;
  String nome;
  String distancia;
  String data;
  String horario;
  bool concluido;

  LocalRoteiro({
    required this.numero,
    required this.nome,
    this.distancia = '',
    required this.data,
    required this.horario,
    this.concluido = false,
  });
}

// ── Página ────────────────────────────────────────────────────────────────────
class RoteiroPage extends StatefulWidget {
  const RoteiroPage({super.key});

  @override
  State<RoteiroPage> createState() => _RoteiroPageState();
}

class _RoteiroPageState extends State<RoteiroPage> {
  final List<LocalRoteiro> _locais = [
    LocalRoteiro(
      numero: '01',
      nome: 'Visita a Torre Eiffel',
      distancia: '',
      data: '10/06/2026',
      horario: '09:30HRS',
      concluido: true,
    ),
    LocalRoteiro(
      numero: '02',
      nome: 'Museu do Louvre',
      distancia: '4 KM DE DISTANCIA',
      data: '10/06/2026',
      horario: '11:30HRS',
      concluido: true,
    ),
    LocalRoteiro(
      numero: '03',
      nome: 'Catedral de Notre-Dame',
      distancia: '2.3 KM DE DISTANCIA',
      data: '10/06/2026',
      horario: '13:30HRS',
      concluido: true,
    ),
    LocalRoteiro(
      numero: '04',
      nome: 'Jardim de Luxemburgo',
      distancia: '6 KM DE DISTANCIA',
      data: '10/06/2026',
      horario: '14:00HRS',
      concluido: true,
    ),
    LocalRoteiro(
      numero: '05',
      nome: 'Arco do Triunfo',
      distancia: '1.3 KM DE DISTANCIA',
      data: '10/06/2026',
      horario: '16:40HRS',
      concluido: false,
    ),
  ];

  // ── Cadastro ──────────────────────────────────────────────────────────────
  void _abrirCadastro() {
    final tituloCtrl   = TextEditingController();
    final distanciaCtrl = TextEditingController();
    final dataCtrl     = TextEditingController(text: '10/06/2026');
    final horarioCtrl  = TextEditingController(text: '09:30HRS');

    _mostrarModal(
      titulo: 'Cadastro de Local',
      tituloCtrl: tituloCtrl,
      distanciaCtrl: distanciaCtrl,
      dataCtrl: dataCtrl,
      horarioCtrl: horarioCtrl,
      botaoLabel: 'Cadastrar Local',
      onSalvar: () {
        if (tituloCtrl.text.trim().isEmpty) return;
        setState(() {
          final numero = (_locais.length + 1).toString().padLeft(2, '0');
          _locais.add(LocalRoteiro(
            numero: numero,
            nome: tituloCtrl.text.trim(),
            distancia: distanciaCtrl.text.trim(),
            data: dataCtrl.text.trim(),
            horario: horarioCtrl.text.trim(),
          ));
        });
        Navigator.pop(context);
      },
    );
  }

  // ── Edição ────────────────────────────────────────────────────────────────
  void _abrirEdicao(int index) {
    final local        = _locais[index];
    final tituloCtrl   = TextEditingController(text: local.nome);
    final distanciaCtrl = TextEditingController(text: local.distancia);
    final dataCtrl     = TextEditingController(text: local.data);
    final horarioCtrl  = TextEditingController(text: local.horario);

    _mostrarModal(
      titulo: 'Editar Local',
      tituloCtrl: tituloCtrl,
      distanciaCtrl: distanciaCtrl,
      dataCtrl: dataCtrl,
      horarioCtrl: horarioCtrl,
      botaoLabel: 'Salvar Alterações',
      onSalvar: () {
        setState(() {
          _locais[index]
            ..nome      = tituloCtrl.text.trim()
            ..distancia = distanciaCtrl.text.trim()
            ..data      = dataCtrl.text.trim()
            ..horario   = horarioCtrl.text.trim();
        });
        Navigator.pop(context);
      },
    );
  }

  // ── Modal compartilhado ───────────────────────────────────────────────────
  void _mostrarModal({
    required String titulo,
    required TextEditingController tituloCtrl,
    required TextEditingController distanciaCtrl,
    required TextEditingController dataCtrl,
    required TextEditingController horarioCtrl,
    required String botaoLabel,
    required VoidCallback onSalvar,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título do modal
                Center(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101828),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Nome do local
                _labelModal('TÍTULO DA VISITA'),
                _campoModal(
                  controller: tituloCtrl,
                  hint: 'Ex: Visita à Torre Eiffel',
                  icone: Icons.location_on_outlined,
                ),
                const SizedBox(height: 14),

                // Distância
                _labelModal('DISTÂNCIA (opcional)'),
                _campoModal(
                  controller: distanciaCtrl,
                  hint: 'Ex: 2.3 KM DE DISTANCIA',
                  icone: Icons.straighten_outlined,
                ),
                const SizedBox(height: 14),

                // Data e Horário lado a lado
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _labelModal('DATA'),
                          _campoModalData(dataCtrl),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _labelModal('HORÁRIO'),
                          _campoModal(
                            controller: horarioCtrl,
                            hint: '09:30HRS',
                            icone: Icons.access_time_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Botão salvar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onSalvar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF23D2B5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      botaoLabel,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Botão cancelar
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancelar',
                        style: TextStyle(color: Color(0xFF64748B))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── DatePicker ────────────────────────────────────────────────────────────
  Future<void> _selecionarData(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 6, 10),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: Color(0xFF23D2B5)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF101828)),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Título ──────────────────────────────────────────
            const Text(
              'Visitas dia 10/06/26',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 18),

            // ── Lista de locais ──────────────────────────────────
            ...List.generate(_locais.length, (i) {
              final local = _locais[i];
              return GestureDetector(
                onTap: () => _abrirEdicao(i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Número circular (meio azul)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F2FE),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          local.numero,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF0284C7),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Detalhes da Visita (Título, Subtítulo, Distância)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              local.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${local.data} • ${local.horario}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (local.distancia.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                local.distancia.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Checkbox para Concluir (toggles status)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            local.concluido = !local.concluido;
                          });
                        },
                        child: Icon(
                          local.concluido
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: local.concluido
                              ? const Color(0xFF23D2B5)
                              : const Color(0xFFD0D5DD),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Ícone Lápis (Edição)
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            // ── Botão Adicionar Local ────────────────────────────
            GestureDetector(
              onTap: _abrirCadastro,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Adicionar Local +',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF101828),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Botão Verificar Rotas ────────────────────────────
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Verificar Rotas',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF101828),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Ilustração ───────────────────────────────────────
            Center(
              child: Image.asset(
                'assets/images/imagem_login.png',
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 3),
    );
  }

  // ── Helpers do modal ──────────────────────────────────────────────────────
  Widget _labelModal(String texto) => Padding(
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

  InputDecoration _decoModal(
          {required String hint, IconData? icone}) =>
      InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: icone != null
            ? Icon(icone, color: const Color(0xFF23D2B5), size: 20)
            : null,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
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
              const BorderSide(color: Color(0xFF23D2B5), width: 1.5),
        ),
      );

  Widget _campoModal({
    required TextEditingController controller,
    required String hint,
    required IconData icone,
  }) =>
      TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: _decoModal(hint: hint, icone: icone),
      );

  Widget _campoModalData(TextEditingController ctrl) => TextField(
        controller: ctrl,
        readOnly: true,
        onTap: () => _selecionarData(ctrl),
        style: const TextStyle(fontSize: 13),
        decoration: _decoModal(
          hint: 'dd/mm/aaaa',
          icone: Icons.calendar_today_outlined,
        ),
      );
}
