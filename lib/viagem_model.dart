// viagem_model.dart
// Modelo compartilhado entre home_page.dart e detalhes_viagem_page.dart.
// Importar este arquivo em ambas as páginas evita importação circular.

class Viagem {
  final String destino;
  final String periodo;
  final String imagemUrl;
  final bool confirmada;

  const Viagem({
    required this.destino,
    required this.periodo,
    required this.imagemUrl,
    this.confirmada = true,
  });
}
