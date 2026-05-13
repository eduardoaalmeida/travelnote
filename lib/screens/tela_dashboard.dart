import 'package:flutter/material.dart';
import 'tela_cadastro_viagem.dart';
import 'tela_perfil.dart';
import 'tela_agenda.dart';
import '../widgets/modal_notificacoes.dart';
import '../widgets/navbar.dart';

class TelaDashboard extends StatelessWidget {
  const TelaDashboard({super.key});

  static const Color azulHeader = Color(0xFF4FA7E1);
  static const Color verdeBotoes = Color(0xFF20C294);
  static const Color cinzaFundo = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: cinzaFundo,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: azulHeader,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 50, 15, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/perfil.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Olá, Eduardo!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: const Color(0xFFF8F9FA),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                            ),
                            builder: (context) {
                              return const ModalNotificacoes();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: -22,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: screenWidth * 0.75,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2DD4BF), Color(0xFF10B981)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TelaCadastroViagem()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Nova Viagem +',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 45),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Próximas Viagens',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              children: [
                _buildTravelCard('Paris', '10 à 18 Jun', 'assets/images/paris.png'),
                _buildTravelCard('Londres', '22 à 30 Jul', 'assets/images/london.png'),
                _buildTravelCard('Nova York', '05 à 12 Set', 'assets/images/ny.png'),
                _buildTravelCard('Roma', '15 à 22 Out', 'assets/images/rome.png'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2DD4BF), Color(0xFF10B981)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.2),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Viagens Anteriores',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Navbar(
        currentIndex: 1, // Dashboard selecionado
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TelaPerfil()));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TelaAgenda()));
          }
        },
      ),
    );
  }

  Widget _buildTravelCard(String city, String date, String imagePath) {
    // Mapa de fotos "premium" selecionadas manualmente para o seu demo
    final Map<String, String> fotosPremium = {
      'Paris': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400&h=400&fit=crop',
      'Londres': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400&h=400&fit=crop',
      'Nova York': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=400&h=400&fit=crop',
      'Roma': 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=400&h=400&fit=crop',
    };

    // Pega a foto premium ou usa uma busca genérica de alta qualidade como fallback
    final String imageUrl = fotosPremium[city] ?? 'https://loremflickr.com/400/400/${city.replaceAll(' ', ',')},landmark/all';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[100],
                    child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  city,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF22D3A5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
