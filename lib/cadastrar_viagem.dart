import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future<String> _buscarImagemDoDestino(String destino) async {
    const apiKey = 'rBNcrwVXtidr63AzwXo13F5vqvI1OAS1s4b53pM7OUJqScRs3nPdDmOZ';

    final destinoFormatado = Uri.encodeComponent('$destino turismo cidade');
    final url = Uri.parse(
      'https://api.pexels.com/v1/search?query=$destinoFormatado&per_page=1&locale=pt-BR',
    );

    final response = await http.get(url, headers: {'Authorization': apiKey});

    if (response.statusCode == 200) {
      final dados = jsonDecode(response.body);

      if (dados['photos'] != null && dados['photos'].isNotEmpty) {
        return dados['photos'][0]['src']['medium'];
      }
    }

    return '';
  }

  Future<void> _cadastrarViagem() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para cadastrar uma viagem'),
        ),
      );
      return;
    }

    if (_destinoController.text.isEmpty ||
        _dataInicio == null ||
        _dataFim == null ||
        _orcamentoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final imagemUrl = await _buscarImagemDoDestino(_destinoController.text);
    await FirebaseFirestore.instance.collection('viagens').add({
      'destino': _destinoController.text,
      'dataInicio': Timestamp.fromDate(_dataInicio!),
      'dataFim': Timestamp.fromDate(_dataFim!),
      'orcamento': _orcamentoController.text,
      'tipo': _selectedTipo,
      'anotacoes': _anotacoesController.text,
      'imagemUrl': imagemUrl,

      // Campos que vinculam a viagem ao usuário logado
      'usuarioId': usuario.uid,
      'criado_por': usuario.email ?? '',

      'criadoEm': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sucesso!'),
        content: Text(
          'Viagem para ${_destinoController.text} cadastrada com sucesso!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
      backgroundColor: Theme.of(context).cardColor,
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Text(
                  'Selecione o tipo de viagem',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      fillColor: Theme.of(context).cardColor,
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

  String _formatarOrcamento(String valor) {
    final apenasNumeros = valor.replaceAll(RegExp(r'[^0-9]'), '');

    if (apenasNumeros.isEmpty) {
      return '';
    }

    final valorInteiro = int.parse(apenasNumeros);
    final valorFormatado = (valorInteiro / 100).toStringAsFixed(2);

    return valorFormatado.replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
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

              Center(
                child: Text(
                  'Cadastro de Viagem',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Onde começa sua\n',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.15,
                      ),
                    ),
                    const TextSpan(
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

              Text(
                'Preencha os detalhes para que possamos organizar cada momento especial do seu roteiro.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 30),

              _buildLabel('DESTINO'),
              TextField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                controller: _orcamentoController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final formatted = _formatarOrcamento(newValue.text);
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }),
                ],
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
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedIcon,
                        color: const Color(0xFF0284C7),
                        size: 24,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedTipo,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedSubtitle,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
                  fillColor: Theme.of(context).cardColor,
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
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
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
                  onPressed: _cadastrarViagem,
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
    );
  }
}
