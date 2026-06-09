import 'package:cloud_firestore/cloud_firestore.dart';

class Gasto {
  final String? id;
  final String viagemId;
  final String descricao;
  final double valor;
  final String categoria;
  final DateTime data;
  final String criadoPor;

  Gasto({
    this.id,
    required this.viagemId,
    required this.descricao,
    required this.valor,
    required this.categoria,
    required this.data,
    required this.criadoPor,
  });

  factory Gasto.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Gasto(
      id: doc.id,
      viagemId: data['viagemId'] ?? '',
      descricao: data['descricao'] ?? '',
      valor: (data['valor'] as num?)?.toDouble() ?? 0,
      categoria: data['categoria'] ?? 'Outros',
      data: (data['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
      criadoPor: data['criado_por'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'viagemId': viagemId,
        'descricao': descricao,
        'valor': valor,
        'categoria': categoria,
        'data': Timestamp.fromDate(data),
        'criado_por': criadoPor,
        'criado_em': FieldValue.serverTimestamp(),
      };

  static const List<String> categorias = [
    'Transporte',
    'Hospedagem',
    'Alimentação',
    'Passeios',
    'Compras',
    'Saúde',
    'Outros',
  ];
}