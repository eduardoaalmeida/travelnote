import 'package:flutter/material.dart';
import 'viagens_page.dart';       // para navegar ao tocar em notificação de viagem
import 'historico_viagens_page.dart'; // para navegar ao tocar em notificação de orçamento

// ─────────────────────────────────────────────
// MODELO
// ─────────────────────────────────────────────
enum TipoNotificacao {
  contagemRegressiva,
  orcamentoExcedido,
  eventoAgendado,
  localMarcado,
  viagemCompartilhada,
}

class Notificacao {
  final TipoNotificacao tipo;
  final String titulo;
  final String descricao;
  final String tempo;
  bool lida;

  Notificacao({
    required this.tipo,
    required this.titulo,
    required this.descricao,
    required this.tempo,
    this.lida = false,
  });
}

// ─────────────────────────────────────────────
// DADOS MOCKADOS
// ─────────────────────────────────────────────
final List<Notificacao> _notificacoesMock = [
  Notificacao(
    tipo: TipoNotificacao.contagemRegressiva,
    titulo: 'Contagem regressiva',
    descricao: 'Paris começa em 5 dias',
    tempo: 'Agora mesmo',
    lida: false,
  ),
  Notificacao(
    tipo: TipoNotificacao.orcamentoExcedido,
    titulo: 'Orçamento excedido',
    descricao: 'Passou R\$ 320 do previsto.',
    tempo: 'Há 10 min',
    lida: false,
  ),
  Notificacao(
    tipo: TipoNotificacao.eventoAgendado,
    titulo: 'Evento agendado',
    descricao: 'Jantar com Amigos amanhã 18:30',
    tempo: 'Há 1 hora',
    lida: false,
  ),
  Notificacao(
    tipo: TipoNotificacao.localMarcado,
    titulo: 'Local marcado',
    descricao: 'Torre Eiffel visitada!',
    tempo: 'Há 2 horas',
    lida: true,
  ),
  Notificacao(
    tipo: TipoNotificacao.viagemCompartilhada,
    titulo: 'Viagem compartilhada',
    descricao: 'Maria aceitou o convite.',
    tempo: 'Há 3 horas',
    lida: true,
  ),
];

// ─────────────────────────────────────────────
// PÁGINA
// ─────────────────────────────────────────────
class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  final List<Notificacao> _notificacoes = List.from(_notificacoesMock);

  int get _novasCount => _notificacoes.where((n) => !n.lida).length;

  // Configurações visuais por tipo de notificação
  _ConfigNotificacao _config(TipoNotificacao tipo) {
    switch (tipo) {
      case TipoNotificacao.contagemRegressiva:
        return _ConfigNotificacao(
          icone: Icons.timer_outlined,
          corFundo: const Color(0xFFE0F7F0),
          corIcone: const Color(0xFF1BCE8A),
        );
      case TipoNotificacao.orcamentoExcedido:
        return _ConfigNotificacao(
          icone: Icons.warning_amber_rounded,
          corFundo: const Color(0xFFFFF0F0),
          corIcone: const Color(0xFFE53935),
        );
      case TipoNotificacao.eventoAgendado:
        return _ConfigNotificacao(
          icone: Icons.calendar_today_outlined,
          corFundo: const Color(0xFFFFF8E1),
          corIcone: const Color(0xFFFFA726),
        );
      case TipoNotificacao.localMarcado:
        return _ConfigNotificacao(
          icone: Icons.check_circle_outline,
          corFundo: const Color(0xFFF3F4F6),
          corIcone: const Color(0xFF9E9E9E),
        );
      case TipoNotificacao.viagemCompartilhada:
        return _ConfigNotificacao(
          icone: Icons.person_add_outlined,
          corFundo: const Color(0xFFF3F4F6),
          corIcone: const Color(0xFF9E9E9E),
        );
    }
  }

  // Navega para a tela certa dependendo do tipo de notificação
  void _aoTocar(Notificacao notificacao) {
    // Marca como lida
    setState(() => notificacao.lida = true);

    switch (notificacao.tipo) {
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
          MaterialPageRoute(builder: (_) => const HistoricoViagensPage()),
        );
        break;
    }
  }

  void _marcarTodasLidas() {
    setState(() {
      for (final n in _notificacoes) {
        n.lida = true;
      }
    });
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Notificações',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            if (_novasCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
      body: _notificacoes.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma notificação.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              itemCount: _notificacoes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = _notificacoes[index];
                final config = _config(notif.tipo);
                return _buildCardNotificacao(notif, config);
              },
            ),
      // Sem bottomNavigationBar aqui — fica centralizado no bottom_nav_bar.dart
    );
  }

  Widget _buildCardNotificacao(
      Notificacao notif, _ConfigNotificacao config) {
    return GestureDetector(
      onTap: () => _aoTocar(notif),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          // Destaque visual para não lidas
          color: notif.lida ? Colors.white : const Color(0xFFF0FAF6),
          borderRadius: BorderRadius.circular(14),
          border: notif.lida
              ? null
              : Border.all(color: const Color(0xFFD0F0E4), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone colorido
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
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.titulo,
                    style: TextStyle(
                      fontWeight: notif.lida
                          ? FontWeight.w500
                          : FontWeight.w700,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.descricao,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.tempo,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            // Bolinha verde para não lidas
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

// ── Helper interno ─────────────────────────────────
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