// viagem_model.dart
// Modelo compartilhado — importe este arquivo em qualquer tela
// que precise da classe Viagem. Nunca duplique esta classe.
//
// Campos obrigatórios (usados por home_page e detalhes_viagem_page):
//   destino, periodo, imagemUrl, confirmada
//
// Campos opcionais (usados por viagens_page e historico_viagens_page):
//   dataInicio, dataFim, orcamento, anotacoes
// São opcionais para não quebrar quem cria Viagem sem eles.

class Viagem {
  String destino;
  String imagemUrl;
  bool confirmada;

  // Usado por home_page.dart e detalhes_viagem_page.dart
  String periodo;

  // Usado por viagens_page.dart e historico_viagens_page.dart
  String dataInicio;
  String dataFim;
  String orcamento;
  String anotacoes;
  String tipo;

  Viagem({
    required this.destino,
    required this.imagemUrl,
    this.confirmada = true,
    // periodo deriva de dataInicio/dataFim se não for passado diretamente
    String? periodo,
    this.dataInicio = '',
    this.dataFim = '',
    this.orcamento = '',
    this.anotacoes = '',
    this.tipo = 'Lazer',
  }) : periodo = periodo ?? _derivarPeriodo(dataInicio, dataFim);

  // Gera "10 Jun à 18 Jun" a partir das datas "10/06/2026" e "18/06/2026"
  // Se periodo for passado diretamente, usa ele (compatível com home_page)
  static String _derivarPeriodo(String inicio, String fim) {
    if (inicio.isEmpty || fim.isEmpty) return '';
    try {
      final pi = inicio.split('/');
      final pf = fim.split('/');
      const m = [
        '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
        'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
      ];
      final mi = int.tryParse(pi[1]) ?? 0;
      final mf = int.tryParse(pf[1]) ?? 0;
      return '${pi[0]} ${m[mi]} à ${pf[0]} ${m[mf]}';
    } catch (_) {
      return '';
    }
  }
}