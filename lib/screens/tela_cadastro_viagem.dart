import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class TelaCadastroViagem extends StatefulWidget {
  const TelaCadastroViagem({super.key});

  @override
  State<TelaCadastroViagem> createState() => _TelaCadastroViagemState();
}

class _TelaCadastroViagemState extends State<TelaCadastroViagem> {
  final TextEditingController _controllerInicio = TextEditingController();
  final TextEditingController _controllerFim = TextEditingController();
  
  String _tipoSelecionado = 'Negócios';
  String _subtituloSelecionado = 'Trabalho e reuniões';
  IconData _iconSelecionado = Icons.business_center_outlined;

  final maskData = MaskTextInputFormatter(
    mask: "##/##/####", 
    filter: {"#": RegExp(r'[0-9]')}
  );

  Future<void> _selecionarData(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // Função para abrir o Seletor (Modal Bottom Sheet)
  void _abrirSeletorTipo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 20),
              const Text('Selecione o Tipo da Viagem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildOpcaoTipo('Negócios', 'Trabalho e reuniões', Icons.business_center_outlined),
              _buildOpcaoTipo('Lazer', 'Férias e diversão', Icons.beach_access_outlined),
              _buildOpcaoTipo('Trabalho', 'Projetos e eventos', Icons.work_outline),
              _buildOpcaoTipo('Família', 'Visita a parentes', Icons.family_restroom_outlined),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOpcaoTipo(String titulo, String subtitulo, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A237E)),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitulo),
      onTap: () {
        setState(() {
          _tipoSelecionado = titulo;
          _subtituloSelecionado = subtitulo;
          _iconSelecionado = icon;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Image.asset('assets/images/logo_completa.png', height: 50),
                    const Spacer(flex: 2),
                  ],
                ),
                const SizedBox(height: 30),
                const Center(
                  child: Text('Cadastro de Viagem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                ),
                const SizedBox(height: 20),
                const Text('Onde começa sua\npróxima história?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E), height: 1.2)),
                const SizedBox(height: 10),
                const Text('Preencha os detalhes para que possamos organizar cada momento especial do seu roteiro.', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 30),
                
                _buildLabel('DESTINO'),
                _buildTextField(hint: 'Para onde você vai?', icon: Icons.location_on_outlined),
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('INICIO'),
                          _buildTextField(
                            hint: 'DD/MM/AAAA',
                            icon: Icons.calendar_today_outlined,
                            controller: _controllerInicio,
                            formatter: maskData,
                            readOnly: true,
                            onTap: () => _selecionarData(context, _controllerInicio),
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
                          _buildTextField(
                            hint: 'DD/MM/AAAA',
                            icon: Icons.calendar_today_outlined,
                            controller: _controllerFim,
                            formatter: maskData,
                            readOnly: true,
                            onTap: () => _selecionarData(context, _controllerFim),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                _buildLabel('ORÇAMENTO PREVISTO'),
                _buildTextField(hint: '0,00', icon: Icons.attach_money_outlined, keyboardType: TextInputType.number),
                
                const SizedBox(height: 20),
                
                _buildLabel('TIPO DA VIAGEM'),
                // Campo Select de Tipo de Viagem
                GestureDetector(
                  onTap: _abrirSeletorTipo,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(_iconSelecionado, color: const Color(0xFF1A237E), size: 28),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_tipoSelecionado, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(_subtituloSelecionado, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                _buildLabel('ANOTAÇÕES'),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Ex: Visitar o museu local, jantar no restaurante indicado...',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                
                const SizedBox(height: 30),
                Container(
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2DD4BF), Color(0xFF10B981)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Cadastrar Viagem', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildTextField({
    required String hint, 
    required IconData icon, 
    TextEditingController? controller,
    TextInputFormatter? formatter,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      inputFormatters: formatter != null ? [formatter] : [],
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}
