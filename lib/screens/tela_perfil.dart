import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import 'tela_dashboard.dart';
import 'tela_agenda.dart';
import 'tela_login.dart';
import 'tela_termos.dart';

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meu Perfil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4FA7E1).withOpacity(0.3), width: 2),
                ),
                child: const CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage('assets/images/perfil.png'),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Eduardo Andrade',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
            ),
            const Text(
              'eduardo@gmail.com',
              style: TextStyle(fontSize: 16, color: Color(0xFF4FA7E1)),
            ),
            const SizedBox(height: 40),
            
            _buildMenuItem(Icons.person_outline, 'Dados Pessoais'),
            _buildMenuItem(Icons.map_outlined, 'Minhas Viagens'),
            _buildMenuItem(Icons.settings_outlined, 'Configurações'),
            _buildMenuItem(Icons.verified_user_outlined, 'Termos de Privacidade', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TelaTermos()),
              );
            }),
            _buildMenuItem(Icons.logout, 'Sair', color: Colors.red, isLast: true, onTap: () {
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const TelaLogin()),
                (route) => false
              );
            }),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Navbar(
        currentIndex: 0, 
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TelaDashboard()));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TelaAgenda()));
          }
        },
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {Color color = Colors.black, bool isLast = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color == Colors.red ? Colors.red : const Color(0xFF4FA7E1)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}
