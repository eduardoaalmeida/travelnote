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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 42),
                decoration: const BoxDecoration(
                  color: Color(0xFF429EDB),
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
                              backgroundImage: AssetImage(
                                'assets/images/perfil.png',
                              ),
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
                                final data =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>?;
                                nome = data?['nome'] ?? 'Usuário';
                              } else if (FirebaseAuth
                                      .instance
                                      .currentUser
                                      ?.displayName !=
                                  null) {
                                nome = FirebaseAuth
                                    .instance
                                    .currentUser!
                                    .displayName!;
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
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -23,
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 44, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Próximas Viagens',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('viagens')
                        .where(
                          'usuarioId',
                          isEqualTo:
                              FirebaseAuth.instance.currentUser?.uid ?? '',
                        )
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
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      String formatarData(dynamic data) {
                        if (data is Timestamp) {
                          final date = data.toDate();
                          return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                        }

                        if (data is String) {
                          return data;
                        }

                        return '';
                      }

                      final viagens = docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        return Viagem(
                          id: doc.id,
                          destino: data['destino'] ?? '',
                          imagemUrl:
                              data['imagemUrl'] ??
                              'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
                          dataInicio: formatarData(data['dataInicio']),
                          dataFim: formatarData(data['dataFim']),
                          orcamento: data['orcamento'] ?? '',
                          anotacoes: data['anotacoes'] ?? '',
                          tipo: data['tipo'] ?? 'Lazer',
                          confirmada: data['confirmada'] ?? true,
                        );
                      }).toList();

                      DateTime? converterData(String data) {
                        try {
                          final partes = data.split('/');

                          if (partes.length == 3) {
                            return DateTime(
                              int.parse(partes[2]),
                              int.parse(partes[1]),
                              int.parse(partes[0]),
                            );
                          }
                        } catch (_) {}

                        return null;
                      }

                      final hoje = DateTime.now();
                      final hojeSemHora = DateTime(
                        hoje.year,
                        hoje.month,
                        hoje.day,
                      );

                      final proximas = viagens.where((viagem) {
                        final dataFim = converterData(viagem.dataFim);

                        if (dataFim == null) return false;

                        return dataFim.isAtSameMomentAs(hojeSemHora) ||
                            dataFim.isAfter(hojeSemHora);
                      }).toList();

                      proximas.sort((a, b) {
                        final dataA = converterData(a.dataInicio);
                        final dataB = converterData(b.dataInicio);

                        if (dataA == null || dataB == null) return 0;

                        return dataA.compareTo(dataB);
                      });

                      final proximasLimitadas = proximas.toList();

                      if (proximasLimitadas.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: Text(
                              'Nenhuma próxima viagem cadastrada.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: proximasLimitadas
                            .map((v) => _ViagemCard(viagem: v))
                            .toList(),
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
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ViagensPage(),
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
        MaterialPageRoute(builder: (_) => DetalhesViagemPage(viagem: viagem)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.015),
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
              child: Image.network(
                viagem.imagemUrl,
                width: 84,
                height: 84,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 84,
                  height: 84,
                  color: const Color(0xFFE0F2FE),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFF0284C7),
                  ),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
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
