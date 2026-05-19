import 'package:flutter/material.dart';
import 'navbar.dart';

class RoteiroPage extends StatefulWidget {
  const RoteiroPage({super.key});

  @override
  State<RoteiroPage> createState() => _RoteiroPageState();
}

class _RoteiroPageState extends State<RoteiroPage> {
  final List<Map<String, dynamic>> _locais = [
    {
      'numero': '01',
      'nome': 'Visita a Torre Eiffel',
      'data': '10/06/2026',
      'horario': '09:30HRS',
      'distancia': null,
      'concluido': true,
    },
    {
      'numero': '02',
      'nome': 'Museu do Louvre',
      'data': '10/06/2026',
      'horario': '11:30HRS',
      'distancia': '4 KM DE DISTANCIA',
      'concluido': true,
    },
    {
      'numero': '03',
      'nome': 'Catedral de Notre-Dame',
      'data': '10/06/2026',
      'horario': '13:30HRS',
      'distancia': '2.3 KM DE DISTANCIA',
      'concluido': true,
    },
    {
      'numero': '04',
      'nome': 'Jardim de Luxemburgo',
      'data': '10/06/2026',
      'horario': '14:00HRS',
      'distancia': '6 KM DE DISTANCIA',
      'concluido': true,
    },
    {
      'numero': '05',
      'nome': 'Arco do Triunfo',
      'data': '10/06/2026',
      'horario': '16:40HRS',
      'distancia': '1.3 KM DE DISTANCIA',
      'concluido': false,
    },
  ];

  void _editarLocal(int index) {
    final nomeController =
        TextEditingController(text: _locais[index]['nome']);
    final horarioController =
        TextEditingController(text: _locais[index]['horario']);
    final distanciaController =
        TextEditingController(text: _locais[index]['distancia'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Editar Local',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do Local',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: horarioController,
              decoration: InputDecoration(
                labelText: 'Horário',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: distanciaController,
              decoration: InputDecoration(
                labelText: 'Distância',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _locais[index]['nome'] = nomeController.text;
                    _locais[index]['horario'] = horarioController.text;
                    _locais[index]['distancia'] =
                        distanciaController.text.isEmpty
                            ? null
                            : distanciaController.text;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23D2B5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Salvar',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _adicionarLocal() {
    final nomeController = TextEditingController();
    final horarioController = TextEditingController();
    final distanciaController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adicionar Local',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do Local',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: horarioController,
              decoration: InputDecoration(
                labelText: 'Horário',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: distanciaController,
              decoration: InputDecoration(
                labelText: 'Distância (opcional)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (nomeController.text.isEmpty) return;
                  setState(() {
                    final numero = (_locais.length + 1)
                        .toString()
                        .padLeft(2, '0');
                    _locais.add({
                      'numero': numero,
                      'nome': nomeController.text,
                      'data': '10/06/2026',
                      'horario': horarioController.text,
                      'distancia': distanciaController.text.isEmpty
                          ? null
                          : distanciaController.text,
                      'concluido': false,
                    });
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23D2B5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Adicionar',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/icon.png', height: 36),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visitas dia 10/06/26',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 18),

            // Lista de locais
            ..._locais.asMap().entries.map((entry) {
              final i = entry.key;
              final local = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Número
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6FAF5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        local['numero'],
                        style: const TextStyle(
                          color: Color(0xFF23D2B5),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            local['nome'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${local['data']} • ${local['horario']}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                          if (local['distancia'] != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              local['distancia'],
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Ações
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _locais[i]['concluido'] =
                                  !_locais[i]['concluido'];
                            });
                          },
                          child: Icon(
                            local['concluido']
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: local['concluido']
                                ? const Color(0xFF23D2B5)
                                : Colors.grey.shade300,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _editarLocal(i),
                          child: const Icon(Icons.edit_outlined,
                              size: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),

            // Botão Adicionar Local
            GestureDetector(
              onTap: _adicionarLocal,
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

            // Botão Verificar Rotas
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

            // Ilustração
            Center(
              child: Image.asset(
                'assets/images/imagem_roteiro.png',
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
}