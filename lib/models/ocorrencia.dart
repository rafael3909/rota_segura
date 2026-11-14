/// Camada de domínio do Rota Segura.
///
/// Uma [Ocorrencia] representa um ponto inseguro relatado por um cidadão
/// (rua sem iluminação, local de assaltos, calçada danificada etc.).
library;

enum CategoriaOcorrencia {
  iluminacao('Iluminação precária'),
  assalto('Assalto / furto'),
  assedio('Assédio'),
  calcada('Calçada danificada'),
  alagamento('Alagamento'),
  terrenoAbandonado('Imóvel / terreno abandonado'),
  outro('Outro');

  const CategoriaOcorrencia(this.label);

  final String label;

  /// Converte o texto salvo no banco para o enum.
  /// Valores desconhecidos caem em [CategoriaOcorrencia.outro].
  static CategoriaOcorrencia fromName(String? name) {
    return CategoriaOcorrencia.values.firstWhere(
      (c) => c.name == name,
      orElse: () => CategoriaOcorrencia.outro,
    );
  }
}

enum NivelRisco {
  baixo(1, 'Baixo'),
  medio(2, 'Médio'),
  alto(3, 'Alto');

  const NivelRisco(this.valor, this.label);

  final int valor;
  final String label;

  static NivelRisco fromValor(int? valor) {
    return NivelRisco.values.firstWhere(
      (n) => n.valor == valor,
      orElse: () => NivelRisco.medio,
    );
  }
}

enum Periodo {
  manha('Manhã'),
  tarde('Tarde'),
  noite('Noite'),
  madrugada('Madrugada');

  const Periodo(this.label);

  final String label;

  static Periodo fromName(String? name) {
    return Periodo.values.firstWhere(
      (p) => p.name == name,
      orElse: () => Periodo.noite,
    );
  }
}

class Ocorrencia {
  const Ocorrencia({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.bairro,
    this.referencia,
    required this.nivelRisco,
    required this.periodo,
    this.resolvida = false,
    this.anonima = false,
    required this.dataRegistro,
  });

  final int? id;
  final String titulo;
  final String descricao;
  final CategoriaOcorrencia categoria;
  final String bairro;
  final String? referencia;
  final NivelRisco nivelRisco;
  final Periodo periodo;
  final bool resolvida;
  final bool anonima;
  final DateTime dataRegistro;

  /// Regra de negócio: uma ocorrência é crítica quando tem risco alto
  /// e ainda não foi resolvida.
  bool get isCritica => nivelRisco == NivelRisco.alto && !resolvida;

  Ocorrencia copyWith({
    int? id,
    String? titulo,
    String? descricao,
    CategoriaOcorrencia? categoria,
    String? bairro,
    String? referencia,
    NivelRisco? nivelRisco,
    Periodo? periodo,
    bool? resolvida,
    bool? anonima,
    DateTime? dataRegistro,
  }) {
    return Ocorrencia(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      bairro: bairro ?? this.bairro,
      referencia: referencia ?? this.referencia,
      nivelRisco: nivelRisco ?? this.nivelRisco,
      periodo: periodo ?? this.periodo,
      resolvida: resolvida ?? this.resolvida,
      anonima: anonima ?? this.anonima,
      dataRegistro: dataRegistro ?? this.dataRegistro,
    );
  }

  /// Mapa no formato das colunas da tabela `ocorrencias` (SQLite).
  /// Booleanos são gravados como 0/1 e datas em ISO-8601.
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria.name,
      'bairro': bairro,
      'referencia': referencia,
      'nivel_risco': nivelRisco.valor,
      'periodo': periodo.name,
      'resolvida': resolvida ? 1 : 0,
      'anonima': anonima ? 1 : 0,
      'data_registro': dataRegistro.toIso8601String(),
    };
  }

  factory Ocorrencia.fromMap(Map<String, Object?> map) {
    return Ocorrencia(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      categoria: CategoriaOcorrencia.fromName(map['categoria'] as String?),
      bairro: map['bairro'] as String,
      referencia: map['referencia'] as String?,
      nivelRisco: NivelRisco.fromValor(map['nivel_risco'] as int?),
      periodo: Periodo.fromName(map['periodo'] as String?),
      resolvida: (map['resolvida'] as int? ?? 0) == 1,
      anonima: (map['anonima'] as int? ?? 0) == 1,
      dataRegistro: DateTime.tryParse(map['data_registro'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  @override
  String toString() => 'Ocorrencia(id: $id, titulo: $titulo, bairro: $bairro)';
}
