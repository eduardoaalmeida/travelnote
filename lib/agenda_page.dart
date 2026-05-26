import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'navbar.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaEvent {
  final String horario;
  final String titulo;
  final String endereco;
  final Color cor;

  _AgendaEvent({
    required this.horario,
    required this.titulo,
    required this.endereco,
    required this.cor,
  });
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  DateTime _novaData = DateTime.now();
  TimeOfDay _novoHorario = const TimeOfDay(hour: 9, minute: 0);

  final Map<DateTime, List<_AgendaEvent>> _events = {};

  List<_AgendaEvent> _getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _events[normalized] ?? [];
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Widget evento(Color cor, String horario, String titulo, String endereco) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(endereco, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
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

        title: const Text('Agenda', style: TextStyle(color: Colors.black)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              child: TableCalendar(
                locale: 'pt_BR',

                focusedDay: _focusedDay,
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },

                calendarFormat: CalendarFormat.month,

                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _getEventsForDay(_selectedDay).isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum evento agendado para este dia.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _getEventsForDay(_selectedDay).length,
                      itemBuilder: (context, index) {
                        final eventoDia = _getEventsForDay(_selectedDay)[index];
                        return evento(
                          eventoDia.cor,
                          eventoDia.horario,
                          eventoDia.titulo,
                          eventoDia.endereco,
                        );
                      },
                    ),
            ),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () async {
                  final bool? added = await _showAddEventDialog(context);
                  if (added == true) {
                    setState(() {});
                  }
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

  Future<bool?> _showAddEventDialog(BuildContext context) async {
    _tituloController.clear();
    _enderecoController.clear();
    _novaData = _selectedDay;
    _novoHorario = const TimeOfDay(hour: 9, minute: 0);

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
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
                            setState(() {
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
                            setState(() {
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
              onPressed: () {
                final titulo = _tituloController.text.trim();
                final endereco = _enderecoController.text.trim();
                if (titulo.isEmpty) {
                  return;
                }

                final normalizedDate = _normalizeDate(_novaData);
                _events
                    .putIfAbsent(normalizedDate, () => [])
                    .add(
                      _AgendaEvent(
                        horario: _novoHorario.format(context),
                        titulo: titulo,
                        endereco: endereco,
                        cor: Colors.cyan,
                      ),
                    );
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23D2B5),
              ),
              child: const Text('Cadastrar Local'),
            ),
          ],
        );
      },
    );
  }
}
