import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'navbar.dart';
import 'viagem_model.dart';

class LocalRoteiro {
  final String id;
  final int ordem;
  String nome;
  String distancia;
  String data;
  String horario;
  bool concluido;

  LocalRoteiro({
    required this.id,
    required this.ordem,
    required this.nome,
    this.distancia = '',
    required this.data,
    required this.horario,
    this.concluido = false,
  });

  factory LocalRoteiro.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LocalRoteiro(
      id: doc.id,
      ordem: data['ordem'] is int ? data['ordem'] as int : 0,
      nome: (data['nome'] ?? data['titulo'] ?? '') as String,
      distancia: (data['distancia'] ?? '') as String,
      data: (data['data'] ?? '') as String,
      horario: (data['horario'] ?? '') as String,
      concluido: (data['concluido'] ?? false) as bool,
    );
  }
}

class RoteiroPage extends StatefulWidget {
  final Viagem viagem;
  final String? roteiroId;
  final String? roteiroTitulo;
  final String? roteiroSubtitulo;

  const RoteiroPage({
    super.key,
    required this.viagem,
    this.roteiroId,
    this.roteiroTitulo,
    this.roteiroSubtitulo,
  });

  @override
  State<RoteiroPage> createState() => _RoteiroPageState();
}

class _RoteiroPageState extends State<RoteiroPage> {
  final List<LocalRoteiro> _locais = [];
  StreamSubscription<QuerySnapshot>? _subscription;
  late final CollectionReference _locaisRef;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    final viagemRef = FirebaseFirestore.instance
        .collection('viagens')
        .doc(widget.viagem.id);

    _locaisRef = widget.roteiroId == null
        ? viagemRef.collection('locais_roteiro')
        : viagemRef
              .collection('roteiro')
              .doc(widget.roteiroId)
              .collection('locais');

    _subscription = _locaisRef.orderBy('ordem').snapshots().listen((snap) {
      if (!mounted) return;
      setState(() {
        _locais
          ..clear()
          ..addAll(snap.docs.map(LocalRoteiro.fromDoc));
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String get _tituloPagina {
    final subtitulo = widget.roteiroSubtitulo?.trim();
    if (subtitulo != null && subtitulo.isNotEmpty) {
      return 'Visitas $subtitulo';
    }

    final titulo = widget.roteiroTitulo?.trim();
    if (titulo != null && titulo.isNotEmpty) {
      return 'Visitas $titulo';
    }

    return 'Visitas da viagem';
  }

  void _abrirCadastro() {
    final tituloCtrl = TextEditingController();
    final distanciaCtrl = TextEditingController();
    final dataCtrl = TextEditingController(text: widget.viagem.dataInicio);
    final horarioCtrl = TextEditingController(text: '09:30HRS');

    _mostrarModal(
      titulo: 'Cadastro de Local',
      tituloCtrl: tituloCtrl,
      distanciaCtrl: distanciaCtrl,
      dataCtrl: dataCtrl,
      horarioCtrl: horarioCtrl,
      botaoLabel: 'Cadastrar Local',
      onSalvar: () async {
        if (tituloCtrl.text.trim().isEmpty) return;
        Navigator.pop(context);
        await _criarLocal(
          nome: tituloCtrl.text.trim(),
          distancia: distanciaCtrl.text.trim(),
          data: dataCtrl.text.trim(),
          horario: horarioCtrl.text.trim(),
        );
      },
    );
  }

  void _abrirEdicao(int index) {
    final local = _locais[index];
    final tituloCtrl = TextEditingController(text: local.nome);
    final distanciaCtrl = TextEditingController(text: local.distancia);
    final dataCtrl = TextEditingController(text: local.data);
    final horarioCtrl = TextEditingController(text: local.horario);

    _mostrarModal(
      titulo: 'Editar Local',
      tituloCtrl: tituloCtrl,
      distanciaCtrl: distanciaCtrl,
      dataCtrl: dataCtrl,
      horarioCtrl: horarioCtrl,
      botaoLabel: 'Salvar Alteracoes',
      onSalvar: () async {
        if (tituloCtrl.text.trim().isEmpty) return;
        Navigator.pop(context);
        await _atualizarLocal(
          docId: local.id,
          nome: tituloCtrl.text.trim(),
          distancia: distanciaCtrl.text.trim(),
          data: dataCtrl.text.trim(),
          horario: horarioCtrl.text.trim(),
        );
      },
      onExcluir: () async {
        Navigator.pop(context);
        await _excluirLocal(local.id);
      },
    );
  }

  Future<void> _criarLocal({
    required String nome,
    required String distancia,
    required String data,
    required String horario,
  }) async {
    setState(() => _carregando = true);
    try {
      final email = FirebaseAuth.instance.currentUser?.email ?? '';
      await _locaisRef.add({
        'nome': nome,
        'distancia': distancia,
        'data': data,
        'horario': horario,
        'concluido': false,
        'ordem': _locais.length,
        'criado_por': email,
        'criado_em': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _mostrarErro('Erro ao salvar local: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _atualizarLocal({
    required String docId,
    required String nome,
    required String distancia,
    required String data,
    required String horario,
  }) async {
    setState(() => _carregando = true);
    try {
      await _locaisRef.doc(docId).update({
        'nome': nome,
        'distancia': distancia,
        'data': data,
        'horario': horario,
        'atualizado_em': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _mostrarErro('Erro ao atualizar local: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _alternarConcluido(LocalRoteiro local) async {
    try {
      await _locaisRef.doc(local.id).update({
        'concluido': !local.concluido,
        'atualizado_em': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _mostrarErro('Erro ao atualizar status: $e');
    }
  }

  Future<void> _excluirLocal(String docId) async {
    setState(() => _carregando = true);
    try {
      await _locaisRef.doc(docId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Local excluido com sucesso!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _mostrarErro('Erro ao excluir local: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  /// Exclui o roteiro inteiro (locais em batch + documento pai) e volta para
  /// DetalhesViagemPage. Só disponível quando [widget.roteiroId] != null.
  Future<void> _confirmarExcluirRoteiro() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Excluir Roteiro',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Todos os locais de "${_tituloPagina}" serão excluídos permanentemente. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => _carregando = true);
    try {
      // 1. Cancela o stream antes de deletar para evitar rebuilds desnecessários
      await _subscription?.cancel();
      _subscription = null;

      // 2. Exclui todos os documentos da subcoleção de locais em batch
      final locaisSnap = await _locaisRef.get();
      if (locaisSnap.docs.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in locaisSnap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // 3. Exclui o documento pai do roteiro (viagens/{id}/roteiro/{roteiroId})
      await FirebaseFirestore.instance
          .collection('viagens')
          .doc(widget.viagem.id)
          .collection('roteiro')
          .doc(widget.roteiroId)
          .delete();

      if (!mounted) return;

      // 4. Volta para DetalhesViagemPage com snackbar de confirmação
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Roteiro excluído com sucesso!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
      _mostrarErro('Erro ao excluir roteiro: $e');
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarModal({
    required String titulo,
    required TextEditingController tituloCtrl,
    required TextEditingController distanciaCtrl,
    required TextEditingController dataCtrl,
    required TextEditingController horarioCtrl,
    required String botaoLabel,
    required Future<void> Function() onSalvar,
    Future<void> Function()? onExcluir,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                _labelModal('TITULO DA VISITA'),
                _campoModal(
                  controller: tituloCtrl,
                  hint: 'Ex: Visita a Torre Eiffel',
                  icone: Icons.location_on_outlined,
                ),
                const SizedBox(height: 14),

                _labelModal('DISTANCIA (opcional)'),
                _campoModal(
                  controller: distanciaCtrl,
                  hint: 'Ex: 2.3 KM DE DISTANCIA',
                  icone: Icons.straighten_outlined,
                ),
                const SizedBox(height: 14),

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
                          _labelModal('HORARIO'),
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

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _carregando
                        ? null
                        : () {
                            onSalvar();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF23D2B5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      botaoLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                if (onExcluir != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: _carregando
                          ? null
                          : () {
                              onExcluir();
                            },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Excluir item',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Future<void> _selecionarData(TextEditingController ctrl) async {
    final inicial =
        _parseData(ctrl.text) ??
        _parseData(widget.viagem.dataInicio) ??
        DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF23D2B5)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  DateTime? _parseData(String data) {
    final partes = data.split('/');
    if (partes.length != 3) return null;
    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final ano = int.tryParse(partes[2]);
    if (dia == null || mes == null || ano == null) return null;
    return DateTime(ano, mes, dia);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF101828)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/logo_completa.png',
          height: 55,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => RichText(
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tituloPagina,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 18),

            if (_locais.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Nenhum local cadastrado.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ),

            ...List.generate(_locais.length, (i) {
              final local = _locais[i];
              return GestureDetector(
                onTap: () => _abrirEdicao(i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F2FE),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (i + 1).toString().padLeft(2, '0'),
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

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              local.nome,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${local.data} • ${local.horario}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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

                      GestureDetector(
                        onTap: () => _alternarConcluido(local),
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

            GestureDetector(
              onTap: _carregando ? null : _abrirCadastro,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
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

            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
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

            // Botão visível apenas quando há um roteiroId (roteiro específico)
            if (widget.roteiroId != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _carregando ? null : _confirmarExcluirRoteiro,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF3D1515)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFCA5A5),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: _carregando
                            ? Colors.grey
                            : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Excluir Roteiro',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: _carregando
                              ? Colors.grey
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            Center(
              child: Image.asset(
                'assets/images/imagem_login.png',
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 3),
    );
  }

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

  InputDecoration _decoModal({required String hint, IconData? icone}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: icone != null
            ? Icon(icone, color: const Color(0xFF23D2B5), size: 20)
            : null,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 13,
          horizontal: 14,
        ),
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
          borderSide: const BorderSide(color: Color(0xFF23D2B5), width: 1.5),
        ),
      );

  Widget _campoModal({
    required TextEditingController controller,
    required String hint,
    required IconData icone,
  }) => TextField(
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