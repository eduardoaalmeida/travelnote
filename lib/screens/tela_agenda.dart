import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/navbar.dart';
import 'tela_dashboard.dart';
import 'tela_perfil.dart';

class TelaAgenda extends StatefulWidget {
  const TelaAgenda({super.key});

  @override
  State<TelaAgenda> createState() => _TelaAgendaState();
}

class _TelaAgendaState extends State<TelaAgenda> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Calendário Profissional
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TableCalendar(
                locale: 'pt_BR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                // Estilização do Header
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                ),
                // Estilização dos Dias
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFF20C294).withOpacity(0.3),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  selectedDecoration: BoxDecoration(
                    color: const Color(0xFF20C294),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  defaultDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  weekendDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  outsideDaysVisible: false,
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.grey, fontSize: 12),
                  weekendStyle: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Lista de Eventos
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildEventoItem('10:00', 'Check-in do hotel', const Color(0xFF03A9F4)),
                  _buildEventoItem('13:40', 'Almoço com Amigos', const Color(0xFF4CAF50)),
                  _buildEventoItem('19:30', 'Jantar de Negócios', const Color(0xFFFF9800)),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
              child: Container(
                height: 55,
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    '+ Novo Evento',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navbar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TelaPerfil()));
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TelaDashboard()));
          }
        },
      ),
    );
  }

  Widget _buildEventoItem(String hora, String titulo, Color cor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            hora,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
