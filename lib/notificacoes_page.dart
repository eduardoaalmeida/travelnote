import 'dart:async';
import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'viagens_page.dart';
import 'historico_viagens_page.dart';
import 'package:intl/intl.dart';

class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  List<NotificacaoModel> _notificacoes = [];
  StreamSubscription<List<NotificacaoModel>>? _subscription;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _subscription = NotificacaoService.stream().listen((lista) {
      if (!mounted) return;
      setState(() {
        _notificacoes = lista;
        _carregando = false;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  int get _novasCount => _notificacoes.where((n) => !n.lida).length;

  String _formatarTempoNotificacao(String tempoOriginal) {
    try {
      final data = DateTime.parse(tempoOriginal);
      return DateFormat('dd/MM/yyyy HH:mm').format(data);
    } catch (_) {
      return tempoOriginal;
    }
  }

  _ConfigNotificacao _config(TipoNotificacao tipo) {
    switch (tipo) {
      case TipoNotificacao.contagemRegressiva:
        return const _ConfigNotificacao(
          icone: Icons.timer_outlined,
          corFundo: Color(0xFFE0F7F0),
          corIcone: Color(0xFF1BCE8A),
        );
      case TipoNotificacao.orcamentoExcedido:
        return const _ConfigNotificacao(
          icone: Icons.warning_amber_rounded,
          corFundo: Color(0xFFFFF0F0),
          corIcone: Color(0xFFE53935),
        );
      case TipoNotificacao.eventoAgendado:
        return const _ConfigNotificacao(
          icone: Icons.calendar_today_outlined,
          corFundo: Color(0xFFFFF8E1),
          corIcone: Color(0xFFFFA726),
        );
      case TipoNotificacao.localMarcado:
        return const _ConfigNotificacao(
          icone: Icons.check_circle_outline,
          corFundo: Color(0xFFF3F4F6),
          corIcone: Color(0xFF9E9E9E),
        );
      case TipoNotificacao.viagemCompartilhada:
        return const _ConfigNotificacao(
          icone: Icons.person_add_outlined,
          corFundo: Color(0xFFF3F4F6),
          corIcone: Color(0xFF9E9E9E),
        );
    }
  }

  void _aoTocar(NotificacaoModel notif) async {
    if (!notif.lida && notif.id != null) {
      await NotificacaoService.marcarLida(notif.id!);
    }

    if (!mounted) return;

    switch (notif.tipo) {
      case TipoNotificacao.contagemRegressiva:
      case TipoNotificacao.eventoAgendado:
      case TipoNotificacao.localMarcado:
      case TipoNotificacao.viagemCompartilhada:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ViagensPage()),
        );
        break;
      case TipoNotificacao.orcamentoExcedido:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistoricoViagensPage(viagemIdInicial: notif.viagemId),
          ),
        );
        break;
    }
  }

  void _marcarTodasLidas() async {
    await NotificacaoService.marcarTodasLidas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E83DB)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notificações',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            if (_novasCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1BCE8A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_novasCount novas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          if (_novasCount > 0)
            TextButton(
              onPressed: _marcarTodasLidas,
              child: const Text(
                'Marcar lidas',
                style: TextStyle(
                  color: Color(0xFF1E83DB),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _notificacoes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      const Text(
                        'Nenhuma notificação.',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _notificacoes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final notif = _notificacoes[index];
                    final config = _config(notif.tipo);
                    return _buildCard(notif, config);
                  },
                ),
    );
  }

  Widget _buildCard(NotificacaoModel notif, _ConfigNotificacao config) {
    return GestureDetector(
      onTap: () => _aoTocar(notif),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.lida ? Theme.of(context).cardColor : const Color(0xFFF0FAF6),
          borderRadius: BorderRadius.circular(14),
          border: notif.lida ? null : Border.all(color: const Color(0xFFD0F0E4), width: 1),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: config.corFundo,
                shape: BoxShape.circle,
              ),
              child: Icon(config.icone, color: config.corIcone, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.titulo,
                    style: TextStyle(
                      fontWeight: notif.lida ? FontWeight.w500 : FontWeight.w700,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.descricao,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatarTempoNotificacao(notif.tempoRelativo),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            if (!notif.lida)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF1BCE8A),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConfigNotificacao {
  final IconData icone;
  final Color corFundo;
  final Color corIcone;

  const _ConfigNotificacao({
    required this.icone,
    required this.corFundo,
    required this.corIcone,
  });
}