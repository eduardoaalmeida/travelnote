import 'package:flutter/material.dart';

class ModalNotificacoes extends StatelessWidget {
  const ModalNotificacoes({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de arraste do modal
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Notificações',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Lista de Notificações
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildItem('Viagem Confirmada! ✈️', 'Sua viagem para Paris foi confirmada.', 'Agora', const Color(0xFF4FA7E1), Icons.flight_takeoff),
                _buildItem('Lembrete 🏨', 'Check-in amanhã às 10:00.', 'Há 2h', const Color(0xFF20C294), Icons.hotel_outlined),
                _buildItem('Mensagem 💬', 'O guia de Paris enviou uma dica.', 'Há 5h', const Color(0xFFFF9800), Icons.chat_bubble_outline),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildItem(String titulo, String msg, String tempo, Color cor, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: cor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(tempo, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}
