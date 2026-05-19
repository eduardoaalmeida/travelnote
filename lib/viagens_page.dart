import 'package:flutter/material.dart';

class ViagensPage extends StatelessWidget {
  const ViagensPage({super.key});

  Widget viagem(String local, String data, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),

      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF23D2B5)),

        title: Text(local, style: const TextStyle(fontWeight: FontWeight.bold)),

        subtitle: Text(data),

        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Viagens')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            viagem('Paris', '15 Maio - 22 Maio', Icons.flight),

            viagem('Nova York', '02 Junho - 10 Junho', Icons.flight_takeoff),

            viagem('Tóquio', '10 Julho - 18 Julho', Icons.public),
          ],
        ),
      ),
    );
  }
}
