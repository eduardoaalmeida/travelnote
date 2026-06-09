import 'dart:developer'; // <-- O import correto deve ficar aqui no topo!
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

enum TipoNotificacao {
  contagemRegressiva,
  orcamentoExcedido,
  eventoAgendado,
  localMarcado,
  viagemCompartilhada,
}

extension TipoNotificacaoExt on TipoNotificacao {
  String get nome {
    switch (this) {
      case TipoNotificacao.contagemRegressiva:
        return 'contagem_regressiva';
      case TipoNotificacao.orcamentoExcedido:
        return 'orcamento_excedido';
      case TipoNotificacao.eventoAgendado:
        return 'evento_agendado';
      case TipoNotificacao.localMarcado:
        return 'local_marcado';
      case TipoNotificacao.viagemCompartilhada:
        return 'viagem_compartilhada';
    }
  }

  static TipoNotificacao fromString(String s) {
    switch (s) {
      case 'contagem_regressiva':
        return TipoNotificacao.contagemRegressiva;
      case 'orcamento_excedido':
        return TipoNotificacao.orcamentoExcedido;
      case 'evento_agendado':
        return TipoNotificacao.eventoAgendado;
      case 'local_marcado':
        return TipoNotificacao.localMarcado;
      case 'viagem_compartilhada':
        return TipoNotificacao.viagemCompartilhada;
      default:
        return TipoNotificacao.eventoAgendado;
    }
  }
}

class NotificacaoModel {
  final String? id;
  final TipoNotificacao tipo;
  final String titulo;
  final String descricao;
  final DateTime criadoEm;
  final bool lida;
  final String? viagemId;

  NotificacaoModel({
    this.id,
    required this.tipo,
    required this.titulo,
    required this.descricao,
    required this.criadoEm,
    this.lida = false,
    this.viagemId,
  });

  factory NotificacaoModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificacaoModel(
      id: doc.id,
      tipo: TipoNotificacaoExt.fromString(data['tipo'] ?? ''),
      titulo: data['titulo'] ?? '',
      descricao: data['descricao'] ?? '',
      criadoEm: (data['criado_em'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lida: data['lida'] ?? false,
      viagemId: data['viagemId'],
    );
  }

  String get tempoRelativo {
    final diff = DateTime.now().difference(criadoEm);
    if (diff.inMinutes < 1) return 'Agora mesmo';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
    return 'Há ${diff.inDays} dia${diff.inDays > 1 ? 's' : ''}';
  }
}

class NotificacaoService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _email => _auth.currentUser?.email ?? '';

  static CollectionReference get _col => _db.collection('notificacoes');

  static Stream<List<NotificacaoModel>> stream() {
    return _col
        .where('email', isEqualTo: _email)
        .orderBy('criado_em', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => NotificacaoModel.fromDoc(doc)).toList());
  }

  static Future<void> marcarLida(String id) async {
    await _col.doc(id).update({'lida': true});
  }

  static Future<void> marcarTodasLidas() async {
    final snap = await _col
        .where('email', isEqualTo: _email)
        .where('lida', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'lida': true});
    }
    await batch.commit();
  }

  static Future<void> criar({
    required TipoNotificacao tipo,
    required String titulo,
    required String descricao,
    String? viagemId,
  }) async {
    await _col.add({
      'email': _email,
      'tipo': tipo.nome,
      'titulo': titulo,
      'descricao': descricao,
      'lida': false,
      'criado_em': FieldValue.serverTimestamp(),
      'viagemId': ?viagemId,
    });
  }

  static Future<void> verificarContagensRegressivas() async {
    if (_email.isEmpty) return;
    final hoje = DateTime.now();

    final snap = await _db
        .collection('viagens')
        .where('criado_por', isEqualTo: _email)
        .get();

    for (final doc in snap.docs) {
      final data = doc.data();
      final inicioStr = data['dataInicio'] as String? ?? '';
      if (inicioStr.isEmpty) continue;

      final parts = inicioStr.split('/');
      if (parts.length < 3) continue;

      final inicio = DateTime.tryParse(
        '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}',
      );
      if (inicio == null) continue;

      final diasRestantes = inicio.difference(hoje).inDays;
      if (diasRestantes < 0 || diasRestantes > 7) continue;

      final jaExiste = await _col
          .where('email', isEqualTo: _email)
          .where('viagemId', isEqualTo: doc.id)
          .where('tipo', isEqualTo: TipoNotificacao.contagemRegressiva.nome)
          .get();

      if (jaExiste.docs.isEmpty) {
        final descricao = diasRestantes == 0
            ? '${data['destino']} começa hoje!'
            : '${data['destino']} começa em $diasRestantes dia${diasRestantes != 1 ? 's' : ''}';

        await criar(
          tipo: TipoNotificacao.contagemRegressiva,
          titulo: 'Contagem regressiva',
          descricao: descricao,
          viagemId: doc.id,
        );
      }
    }
  }

  static double _parsearOrcamento(dynamic valor) {
    if (valor == null) return 0;
    if (valor is num) return valor.toDouble();
    if (valor is String) {
      final limpo = valor.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(limpo) ?? 0;
    }
    return 0;
  }

  static Future<void> verificarOrcamentosExcedidos() async {
    if (_email.isEmpty) return;

    try {
      final snap = await _db
          .collection('viagens')
          .where('criado_por', isEqualTo: _email)
          .get();

      for (final doc in snap.docs) {
        final data = doc.data();

        final orcamento = _parsearOrcamento(data['orcamento']);
        if (orcamento <= 0) continue;

        final gastosSnap = await _db
            .collection('gastos')
            .where('viagemId', isEqualTo: doc.id)
            .where('criado_por', isEqualTo: _email)
            .get();

        final totalGasto = gastosSnap.docs.fold<double>(
          0,
          (soma, g) => soma + ((g.data()['valor'] as num?)?.toDouble() ?? 0),
        );

        if (totalGasto <= orcamento) continue;

        final excedente = totalGasto - orcamento;

        final notifSnap = await _col
            .where('email', isEqualTo: _email)
            .where('viagemId', isEqualTo: doc.id)
            .where('tipo', isEqualTo: TipoNotificacao.orcamentoExcedido.nome)
            .get();

        bool deveNotificar = notifSnap.docs.isEmpty;

        if (!deveNotificar && notifSnap.docs.isNotEmpty) {
          final docs = List<QueryDocumentSnapshot>.from(notifSnap.docs);
          
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>?;
            final bData = b.data() as Map<String, dynamic>?;

            final aTime = aData?['criado_em'] is Timestamp
                ? (aData!['criado_em'] as Timestamp).toDate()
                : DateTime.now();
            final bTime = bData?['criado_em'] is Timestamp
                ? (bData!['criado_em'] as Timestamp).toDate()
                : DateTime.now();

            return bTime.compareTo(aTime);
          });

          final ultimaDescricao =
              (docs.first.data() as Map<String, dynamic>)['descricao']
                      as String? ??
                  '';
          
          final regExp = RegExp(r'[\d,.]+');
          final match = regExp.firstMatch(
            ultimaDescricao.replaceAll('R\$', '').replaceAll(' ', ''),
          );
          if (match != null) {
            final ultimoExcedente = double.tryParse(
                  match.group(0)!.replaceAll('.', '').replaceAll(',', '.'),
                ) ??
                0;
            if (excedente - ultimoExcedente > orcamento * 0.05) {
              deveNotificar = true;
            }
          }
        }

        if (deveNotificar) {
          final formatador =
              NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
          final excedenteFormatado = formatador.format(excedente);

          await criar(
            tipo: TipoNotificacao.orcamentoExcedido,
            titulo: 'Orçamento excedido',
            descricao:
                '${data['destino']} passou $excedenteFormatado do previsto.',
            viagemId: doc.id,
          );
        }
      }
    } catch (e) {
      log("Erro ao verificar orçamentos excedidos: $e", name: 'NotificacaoService');
    }
  }

  static Future<void> notificarViagemCompartilhada({
    required String destino,
    required String nomeConvidado,
    required String viagemId,
  }) async {
    await criar(
      tipo: TipoNotificacao.viagemCompartilhada,
      titulo: 'Viagem compartilhada',
      descricao: '$nomeConvidado aceitou o convite para $destino.',
      viagemId: viagemId,
    );
  }

  static Future<void> notificarLocalMarcado({
    required String nomeLocal,
    required String viagemId,
  }) async {
    await criar(
      tipo: TipoNotificacao.localMarcado,
      titulo: 'Local marcado',
      descricao: '$nomeLocal visitado!',
      viagemId: viagemId,
    );
  }

  static Future<void> notificarEventoAgendado({
    required String nomeEvento,
    required String horario,
    required String viagemId,
  }) async {
    await criar(
      tipo: TipoNotificacao.eventoAgendado,
      titulo: 'Evento agendado',
      descricao: '$nomeEvento amanhã às $horario',
      viagemId: viagemId,
    );
  }
}