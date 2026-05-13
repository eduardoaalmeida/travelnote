class Tarefa {
  String titulo;
  String descricao;
  bool concluida;

  Tarefa({required this.titulo, required this.descricao, this.concluida = false});

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descricao': descricao,
        'concluida': concluida,
      };

  factory Tarefa.fromMap(Map<String, dynamic> map) => Tarefa(
        titulo: map['titulo'] as String,
        descricao: map['descricao'] as String,
        concluida: map['concluida'] as bool,
      );
}
