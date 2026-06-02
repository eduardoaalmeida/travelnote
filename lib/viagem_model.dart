class Viagem {
  String? id;
  String destino;
  String imagemUrl;
  bool confirmada;

  String periodo;

  String dataInicio;
  String dataFim;
  String orcamento;
  String anotacoes;
  String tipo;

  Viagem({
    this.id,
    required this.destino,
    required this.imagemUrl,
    this.confirmada = true,

    String? periodo,
    this.dataInicio = '',
    this.dataFim = '',
    this.orcamento = '',
    this.anotacoes = '',
    this.tipo = 'Lazer',
  }) : periodo = periodo ?? _derivarPeriodo(dataInicio, dataFim);

  static String _derivarPeriodo(String inicio, String fim) {
    if (inicio.isEmpty || fim.isEmpty) return '';
    try {
      final pi = inicio.split('/');
      final pf = fim.split('/');
      const m = [
        '',
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez',
      ];
      final mi = int.tryParse(pi[1]) ?? 0;
      final mf = int.tryParse(pf[1]) ?? 0;
      return '${pi[0]} ${m[mi]} à ${pf[0]} ${m[mf]}';
    } catch (_) {
      return '';
    }
  }
}
