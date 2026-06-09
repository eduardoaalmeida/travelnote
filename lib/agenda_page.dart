import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'navbar.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaEvent {
  final String id;
  final String horario;
  final String titulo;
  final String endereco;
  final Color cor;
  final DateTime data;
  final bool deRoteiro; // indica se veio de um roteiro de viagem

  _AgendaEvent({
    required this.id,
    required this.horario,
    required this.titulo,
    required this.endereco,
    required this.cor,
    required this.data,
    this.deRoteiro = false,
  });
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _focusedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime _selectedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  DateTime _novaData = DateTime.now();
  TimeOfDay _novoHorario = const TimeOfDay(hour: 9, minute: 0);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _usuarioLogado => _auth.currentUser?.email ?? '';

  CollectionReference get _eventosRef => _db.collection('eventos');

  List<_AgendaEvent> _getEventsForDay(DateTime day, List<_AgendaEvent> todos) {
    return todos.where((e) {
      return e.data.year == day.year &&
          e.data.month == day.month &&
          e.data.day == day.day;
    }).toList();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _deletarEvento(String id) async {
    await _eventosRef.doc(id).delete();
  }

  /// Busca todas as visitas de todos os roteiros do usuário atual
  Future<List<_AgendaEvent>> _buscarVisitasDeRoteiros() async {
    final email = _auth.currentUser?.email ?? '';
    if (email.isEmpty) return [];

    final List<_AgendaEvent> visitas = [];

    try {
      // Busca todas as viagens do usuário
      final viagensSnap = await _db
          .collection('viagens')
          .where('criado_por', isEqualTo: email)
          .get();

      for (final viagemDoc in viagensSnap.docs) {
        // Busca todos os roteiros dessa viagem
        final roteirosSnap = await viagemDoc.reference
            .collection('roteiro')
            .get();

        for (final roteiroDoc in roteirosSnap.docs) {
          // Busca todos os locais/visitas desse roteiro
          final locaisSnap = await roteiroDoc.reference
              .collection('locais')
              .get();

          for (final localDoc in locaisSnap.docs) {
            final dados = localDoc.data();
            final dataStr = (dados['data'] ?? '') as String;
            final dt = _parseData(dataStr);
            if (dt == null) continue;

            final horario = (dados['horario'] ?? '') as String;
            final nome = (dados['nome'] ?? dados['titulo'] ?? '') as String;
            final distancia = (dados['distancia'] ?? '') as String;

            visitas.add(
              _AgendaEvent(
                id: localDoc.id,
                horario: horario,
                titulo: nome,
                endereco: distancia.isNotEmpty
                    ? distancia
                    : viagemDoc['destino'] ?? '',
                cor: const Color(0xFF10B981),
                data: DateTime(dt.year, dt.month, dt.day),
                deRoteiro: true,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar visitas de roteiros: $e');
    }

    return visitas;
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

  Widget _eventoWidget(
    Color cor,
    String horario,
    String titulo,
    String endereco,
    String id,
    bool deRoteiro,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: deRoteiro
            ? Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                width: 1.2,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 15),
          Text(horario, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (deRoteiro)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Roteiro',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(endereco, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          if (!deRoteiro)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Excluir evento'),
                    content: const Text('Deseja excluir este evento?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text(
                          'Excluir',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _deletarEvento(id);
                }
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Agenda',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _eventosRef
            .where('uid', isEqualTo: _auth.currentUser?.uid ?? '')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          // Eventos manuais da coleção 'eventos'
          List<_AgendaEvent> eventosManuals = [];
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final ts = data['data'];
              if (ts == null) continue;
              final dt = (ts as Timestamp).toDate();
              eventosManuals.add(
                _AgendaEvent(
                  id: doc.id,
                  horario: data['horario'] ?? '',
                  titulo: data['titulo'] ?? '',
                  endereco: data['endereco'] ?? '',
                  cor: Colors.cyan,
                  data: DateTime(dt.year, dt.month, dt.day),
                  deRoteiro: false,
                ),
              );
            }
          }

          return FutureBuilder<List<_AgendaEvent>>(
            future: _buscarVisitasDeRoteiros(),
            builder: (context, snapshotRoteiros) {
              final visitasRoteiro = snapshotRoteiros.data ?? [];

              // Mescla eventos manuais + visitas de roteiros
              final List<_AgendaEvent> todosEventos = [
                ...eventosManuals,
                ...visitasRoteiro,
              ];

              // Ordena por data
              todosEventos.sort((a, b) => a.data.compareTo(b.data));

              final eventosDoDia = _getEventsForDay(_selectedDay, todosEventos);

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TableCalendar(
                        locale: 'pt_BR',
                        focusedDay: _focusedDay,
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        eventLoader: (day) {
                          return _getEventsForDay(day, todosEventos);
                        },
                        calendarFormat: CalendarFormat.month,
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarStyle: CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: const Color(0xFF10B981),
                              width: 1.5,
                            ),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          markerDecoration: const BoxDecoration(
                            color: Color(0xFF23D2B5),
                            shape: BoxShape.circle,
                          ),
                          defaultDecoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          weekendDecoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          outsideDecoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledDecoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          holidayDecoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          selectedTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          todayTextStyle: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: snapshot.connectionState == ConnectionState.waiting
                          ? const Center(child: CircularProgressIndicator())
                          : eventosDoDia.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhum evento agendado para este dia.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: eventosDoDia.length,
                              itemBuilder: (context, index) {
                                final ev = eventosDoDia[index];
                                return _eventoWidget(
                                  ev.cor,
                                  ev.horario,
                                  ev.titulo,
                                  ev.endereco,
                                  ev.id,
                                  ev.deRoteiro,
                                );
                              },
                            ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _showAddEventDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF23D2B5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          '+ Novo Evento',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const NavBar(currentIndex: 2),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  Future<void> _showAddEventDialog(BuildContext context) async {
    _tituloController.clear();
    _enderecoController.clear();
    _novaData = _selectedDay;
    _novoHorario = const TimeOfDay(hour: 9, minute: 0);

    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Cadastro de Local'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        labelText: 'Título da Visita',
                        hintText: 'Título da visita',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _enderecoController,
                      decoration: InputDecoration(
                        labelText: 'Endereço',
                        hintText: 'Endereço',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: dialogContext,
                                initialDate: _novaData,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  _novaData = picked;
                                });
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Colors.grey),
                            ),
                            child: Text(
                              '${_novaData.day.toString().padLeft(2, '0')}/${_novaData.month.toString().padLeft(2, '0')}/${_novaData.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: dialogContext,
                                initialTime: _novoHorario,
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  _novoHorario = picked;
                                });
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Colors.grey),
                            ),
                            child: Text(_novoHorario.format(dialogContext)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final titulo = _tituloController.text.trim();
                    final endereco = _enderecoController.text.trim();
                    if (titulo.isEmpty) return;

                    final normalizedDate = _normalizeDate(_novaData);

                    await _eventosRef.add({
                      'titulo': titulo,
                      'endereco': endereco,
                      'horario': _novoHorario.format(context),
                      'data': Timestamp.fromDate(normalizedDate),
                      'uid': _auth.currentUser?.uid ?? '',
                      'usuario_logado': _usuarioLogado,
                      'criado_em': FieldValue.serverTimestamp(),
                    });

                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop(true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF23D2B5),
                  ),
                  child: const Text(
                    'Cadastrar Local',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
