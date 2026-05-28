import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navbar.dart';
import 'viagem_model.dart';
import 'detalhes_viagem.dart';
import 'cadastrar_viagem.dart';
import 'notificacoes_page.dart';
import 'viagens_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ── Header Flat com Botão Sobreposto ──────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 42),
                decoration: const BoxDecoration(
                  color: Color(0xFF429EDB), // Flat Sky Blue
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const CircleAvatar(
                              radius: 22,
                              backgroundImage: AssetImage('assets/images/perfil.png'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('usuarios')
                                .doc(FirebaseAuth.instance.currentUser?.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              String nome = 'Usuário';
                              if (snapshot.hasData && snapshot.data!.exists) {
                                final data = snapshot.data!.data() as Map<String, dynamic>?;
                                nome = data?['nome'] ?? 'Usuário';
                              } else if (FirebaseAuth.instance.currentUser?.displayName != null) {
                                nome = FirebaseAuth.instance.currentUser!.displayName!;
                              }
                              return Text(
                                'Olá, $nome!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      // ── BOTÃO DE NOTIFICAÇÃO ADICIONADO AQUI ──────────
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificacoesPage(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      // ──────────────────────────────────────────────────
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -23, // Metade da altura do botão para sobrepor perfeitamente
                left: 24,
                right: 24,
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CadastrarViagemPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF10B981).withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Nova Viagem +',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Lista de viagens ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 44, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Próximas Viagens',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('viagens')
                        .where('criado_por', isEqualTo: FirebaseAuth.instance.currentUser?.email ?? '')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: Text(
                              'Nenhuma viagem cadastrada.',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        );
                      }
                      
                      final docs = snapshot.data!.docs;
                      final viagens = docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Viagem(
                          id: doc.id,
                          destino: data['destino'] ?? '',
                          imagemUrl: data['imagemUrl'] ?? 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
                          dataInicio: data['dataInicio'] ?? '',
                          dataFim: data['dataFim'] ?? '',
                          orcamento: data['orcamento'] ?? '',
                          anotacoes: data['anotacoes'] ?? '',
                          tipo: data['tipo'] ?? 'Lazer',
                          confirmada: data['confirmada'] ?? true,
                        );
                      }).toList();

                      // Ordena as viagens localmente por data de início de forma crescente
                      try {
                        viagens.sort((a, b) {
                          final partsA = a.dataInicio.split('/');
                          final partsB = b.dataInicio.split('/');
                          if (partsA.length == 3 && partsB.length == 3) {
                            final dateA = DateTime(int.parse(partsA[2]), int.parse(partsA[1]), int.parse(partsA[0]));
                            final dateB = DateTime(int.parse(partsB[2]), int.parse(partsB[1]), int.parse(partsB[0]));
                            return dateA.compareTo(dateB);
                          }
                          return 0;
                        });
                      } catch (_) {}

                      // Exibe até 4 próximas viagens
                      final proximas = viagens.take(4).toList();

                      return Column(
                        children: proximas.map((v) => _ViagemCard(viagem: v)).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const ViagensPage(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Viagens Anteriores',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(currentIndex: 1),
    );
  }
}

class _ViagemCard extends StatelessWidget {
  final Viagem viagem;
  const _ViagemCard({required this.viagem});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DetalhesViagemPage(),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFF2F6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/paris.png',
                width: 84,
                height: 84,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.network(
                  viagem.imagemUrl,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 84,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          viagem.destino,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFFCBD5E1),
                          size: 18,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          viagem.periodo,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF10B981),
                          size: 26,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}