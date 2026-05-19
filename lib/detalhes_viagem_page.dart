import 'package:flutter/material.dart';
import 'navbar.dart';
import 'viagem_model.dart';   // ← modelo isolado (sem circular)
import 'roteiro_page.dart';

// ── Modelo de Compromisso ─────────────────────────────────────────────────────
class Compromisso {
  String titulo;
  String data;
  String horario;

  Compromisso({
    required this.titulo,
    required this.data,
    required this.horario,
  });
}

// ── Página de Detalhes da Viagem ──────────────────────────────────────────────
class DetalhesViagemPage extends StatefulWidget {
  final Viagem viagem;

  const DetalhesViagemPage({super.key, required this.viagem});

  @override
  State<DetalhesViagemPage> createState() => _DetalhesViagemPageState();
}

class _DetalhesViagemPageState extends State<DetalhesViagemPage> {
  final _tituloController = TextEditingController();
  final _dataController = TextEditingController();
  final _horarioController = TextEditingController();

  bool _mostrarFormulario = false;
  int? _editandoIndex;

  final List<Compromisso> _compromissos = [
    Compromisso(titulo: 'Compromisso 1', data: '10/06/2026', horario: '09:00HRS'),
    Compromisso(titulo: 'Compromisso 2', data: '11/06/2026', horario: '14:00HRS'),
    Compromisso(titulo: 'Compromisso 3', data: '13/06/2026', horario: '09:00HRS'),
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _dataController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  void _abrirCadastro() {
    _tituloController.clear();
    _dataController.text = '10/06/2026';
    _horarioController.text = '09:30hrs';
    setState(() {
      _mostrarFormulario = true;
      _editandoIndex = null;
    });
  }

  void _abrirEdicao(int index) {
    _tituloController.text = _compromissos[index].titulo;
    _dataController.text = _compromissos[index].data;
    _horarioController.text = _compromissos[index].horario;
    setState(() {
      _mostrarFormulario = true;
      _editandoIndex = index;
    });
  }

  void _salvar() {
    final titulo = _tituloController.text.trim();
    if (titulo.isEmpty) return;
    setState(() {
      if (_editandoIndex == null) {
        _compromissos.add(Compromisso(
          titulo: titulo,
          data: _dataController.text.trim(),
          horario: _horarioController.text.trim(),
        ));
      } else {
        _compromissos[_editandoIndex!] = Compromisso(
          titulo: titulo,
          data: _dataController.text.trim(),
          horario: _horarioController.text.trim(),
        );
      }
      _mostrarFormulario = false;
      _editandoIndex = null;
    });
  }

  void _excluirCompromisso(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir Compromisso'),
        content: const Text('Tem certeza que deseja excluir este compromisso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _compromissos.removeAt(index));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFEBEB),
              foregroundColor: const Color(0xFFE53935),
              elevation: 0,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _excluirViagem() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir Viagem'),
        content: const Text('Tem certeza que deseja excluir esta viagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFEBEB),
              foregroundColor: const Color(0xFFE53935),
              elevation: 0,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  String _numero(int index) => (index + 1).toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final bool editando = _editandoIndex != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF101828)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/icon.png',
              height: 36,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.airplanemode_active,
                color: Color(0xFF23D2B5),
              ),
            ),
            const SizedBox(width: 8),
            RichText(
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
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Foto + info ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      widget.viagem.imagemUrl,
                      width: 90,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90,
                        height: 80,
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.viagem.destino,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.viagem.periodo,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Formulário inline ────────────────────────
                  if (_mostrarFormulario)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            editando
                                ? 'Editar Compromisso'
                                : 'Cadastro de Compromisso',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _label('TÍTULO'),
                          const SizedBox(height: 6),
                          _campo(
                            controller: _tituloController,
                            hint: editando
                                ? 'Jantar com Amigos'
                                : 'Título do Compromisso',
                            prefixIcon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('DATA'),
                                    const SizedBox(height: 6),
                                    _campo(
                                      controller: _dataController,
                                      hint: '10/06/2026',
                                      prefixIcon: Icons.calendar_today_outlined,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('HORÁRIO'),
                                    const SizedBox(height: 6),
                                    _campo(
                                      controller: _horarioController,
                                      hint: '09:30hrs',
                                      prefixIcon: Icons.access_time_outlined,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _salvar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF23D2B5),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                editando
                                    ? 'Editar Compromisso'
                                    : 'Cadastrar Compromisso',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Lista de compromissos ────────────────────
                  ..._compromissos.asMap().entries.map((e) {
                    final i = e.key;
                    final c = e.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6FAF5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _numero(i),
                              style: const TextStyle(
                                color: Color(0xFF23D2B5),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.titulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF101828),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${c.data} • ${c.horario}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _abrirEdicao(i),
                                child: const Icon(Icons.edit_outlined,
                                    size: 20, color: Colors.grey),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => _excluirCompromisso(i),
                                child: const Icon(Icons.delete_outline,
                                    size: 20,
                                    color: Color(0xFFE53935)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  // ── Adicionar / Cancelar ─────────────────────
                  GestureDetector(
                    onTap: _mostrarFormulario
                        ? () => setState(() {
                              _mostrarFormulario = false;
                              _editandoIndex = null;
                            })
                        : _abrirCadastro,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _mostrarFormulario
                            ? 'Cancelar'
                            : 'Adicionar Compromisso +',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: _mostrarFormulario
                              ? Colors.red
                              : const Color(0xFF101828),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Botões Editar / Excluir viagem ───────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RoteiroPage()),
                          ),
                          icon: const Icon(Icons.edit_outlined,
                              size: 18, color: Color(0xFF101828)),
                          label: const Text(
                            'Editar',
                            style: TextStyle(
                              color: Color(0xFF101828),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            side:
                                const BorderSide(color: Color(0xFFE0E5EC)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _excluirViagem,
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: Color(0xFFE53935)),
                          label: const Text(
                            'Excluir',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            side:
                                const BorderSide(color: Color(0xFFFFD6D6)),
                            backgroundColor: const Color(0xFFFFF0F0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 3),
    );
  }

  Widget _label(String texto) => Text(
        texto,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      );

  Widget _campo({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
  }) =>
      TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon:
              Icon(prefixIcon, color: const Color(0xFF23D2B5), size: 18),
          filled: true,
          fillColor: const Color(0xFFF6F7FB),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      );
}
