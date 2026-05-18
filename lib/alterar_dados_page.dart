import 'package:flutter/material.dart';

class AlterarDadosPage extends StatelessWidget {
  const AlterarDadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Alterar dados',
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            const CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
            ),

            const SizedBox(height: 15),

            const Text(
              'Eduardo Andrade',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const Text(
              'eduardo@gmail.com',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            TextField(
              decoration: InputDecoration(
                labelText: 'CPF',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                labelText: 'Telefone',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () {},

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23D2B5),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                child: const Text(
                  'Alterar Senha',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
