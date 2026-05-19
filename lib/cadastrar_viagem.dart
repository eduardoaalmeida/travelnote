import 'package:flutter/material.dart';

class CadastrarViagemPage extends StatefulWidget {
  const CadastrarViagemPage({super.key});

  @override
  State<CadastrarViagemPage> createState() => _CadastrarViagemPageState();
}

class _CadastrarViagemPageState extends State<CadastrarViagemPage> {
  DateTime? _dataInicio;
  DateTime? _dataFim;
  String _selectedTipo = 'Negócios';
  String _selectedSubtitle = 'Trabalho e reuniões';
  IconData _selectedIcon = Icons.business_center_outlined;

  final TextEditingController _inicioController = TextEditingController();
  final TextEditingController _fimController = TextEditingController();
  final TextEditingController _destinoController = TextEditingController();
  final TextEditingController _orcamentoController = TextEditingController();
  final TextEditingController _anotacoesController = TextEditingController();

  @override
  void dispose() {
    _inicioController.dispose();
    _fimController.dispose();
    _destinoController.dispose();
    _orcamentoController.dispose();
    _anotacoesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0284C7),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0284C7),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _dataInicio = picked;
          _inicioController.text =
              "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        } else {
          _dataFim = picked;
          _fimController.text =
              "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        }
      });
    }
  }

  void _showTipoViagemPicker() {
    final options = [
      {
        'title': 'Lazer',
        'subtitle': 'Passeios e diversão',
        'icon': Icons.beach_access_outlined,
      },
      {
        'title': 'Trabalho',
        'subtitle': 'Compromissos profissionais',
        'icon': Icons.laptop_chromebook_outlined,
      },
      {
        'title': 'Família',
        'subtitle': 'Viagem com familiares',
        'icon': Icons.people_outline,
      },
      {
        'title': 'Negócios',
        'subtitle': 'Trabalho e reuniões',
        'icon': Icons.business_center_outlined,
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                  'Selecione o tipo de viagem',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...options.map((opt) {
                final isSelected = opt['title'] == _selectedTipo;
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE0F2FE)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      opt['icon'] as IconData,
                      color: isSelected
                          ? const Color(0xFF0284C7)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  title: Text(
                    opt['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF0284C7)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    opt['subtitle'] as String,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF0284C7))
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedTipo = opt['title'] as String;
                      _selectedSubtitle = opt['subtitle'] as String;
                      _selectedIcon = opt['icon'] as IconData;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required Widget prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                    ),
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo_completa.png',
                          height: 75,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 25),

                const Center(
                  child: Text(
                    'Cadastro de Viagem',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Onde começa sua\n',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          height: 1.15,
                        ),
                      ),
                      TextSpan(
                        text: 'próxima história?',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0284C7),
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Preencha os detalhes para que possamos organizar cada momento especial do seu roteiro.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 30),

                _buildLabel('DESTINO'),
                TextField(
                  controller: _destinoController,
                  decoration: _buildInputDecoration(
                    hintText: 'Para onde você vai?',
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('INÍCIO'),
                          TextField(
                            readOnly: true,
                            onTap: () => _selectDate(context, true),
                            controller: _inicioController,
                            decoration: _buildInputDecoration(
                              hintText: 'DD/MM/AAAA',
                              prefixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('FIM'),
                          TextField(
                            readOnly: true,
                            onTap: () => _selectDate(context, false),
                            controller: _fimController,
                            decoration: _buildInputDecoration(
                              hintText: 'DD/MM/AAAA',
                              prefixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildLabel('ORÇAMENTO PREVISTO'),
                TextField(
                  controller: _orcamentoController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(
                    hintText: '0,00',
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _buildLabel('TIPO DA VIAGEM'),
                GestureDetector(
                  onTap: _showTipoViagemPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
                        Icon(_selectedIcon, color: const Color(0xFF0284C7), size: 24),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedTipo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedSubtitle,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0284C7),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _buildLabel('ANOTAÇÕES'),
                TextField(
                  controller: _anotacoesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Ex: Visitar o museu local, jantar no restaurante indicado...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 15,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFF0284C7),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF10B981),
                        Color(0xFF059669),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          title: const Text('Sucesso!'),
                          content: Text(
                            'Viagem para ${_destinoController.text.isEmpty ? 'seu destino' : _destinoController.text} foi cadastrada com sucesso!',
                            style: const TextStyle(fontSize: 16),
                          ),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                              ),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'OK',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Cadastrar Viagem',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
}