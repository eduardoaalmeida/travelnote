import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'navbar.dart';
import 'perfil_page.dart';
import 'home_page.dart';
import 'viagens_page.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  Widget evento(Color cor, String horario, String titulo) {
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

          Text(horario),

          const SizedBox(width: 20),

          Expanded(child: Text(titulo)),
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

      body: SingleChildScrollView(
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

                focusedDay: DateTime.now(),
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),

                calendarFormat: CalendarFormat.month,

                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),

            const SizedBox(height: 20),

            evento(Colors.cyan, '10:00', 'Check-in do hotel'),

            evento(Colors.green, '13:40', 'Almoço com Amigos'),

            evento(Colors.orange, '19:30', 'Jantar de Negócios'),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () {},

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23D2B5),
                  foregroundColor: Colors.black,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                child: const Text('+ Novo Evento'),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const NavBar(currentIndex: 2),
    );
  }
}
