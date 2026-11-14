import 'package:rota_segura/data/ocorrencia_repository.dart';
import 'package:rota_segura/models/ocorrencia.dart';

/// Repositório em memória para testar o Provider sem SQLite.
class FakeOcorrenciaRepository implements OcorrenciaRepository {
  FakeOcorrenciaRepository([List<Ocorrencia>? iniciais])
      : _itens = List.of(iniciais ?? []) {
    for (final o in _itens) {
      if (o.id != null && o.id! >= _proximoId) _proximoId = o.id! + 1;
    }
  }

  final List<Ocorrencia> _itens;
  int _proximoId = 1;

  /// Quando `true`, todas as operações lançam exceção.
  bool deveFalhar = false;

  void _verificarFalha() {
    if (deveFalhar) throw Exception('Falha simulada no banco');
  }

  @override
  Future<List<Ocorrencia>> getAll() async {
    _verificarFalha();
    return List.of(_itens);
  }

  @override
  Future<Ocorrencia> insert(Ocorrencia ocorrencia) async {
    _verificarFalha();
    final salva = ocorrencia.copyWith(id: _proximoId++);
    _itens.add(salva);
    return salva;
  }

  @override
  Future<void> update(Ocorrencia ocorrencia) async {
    _verificarFalha();
    final i = _itens.indexWhere((o) => o.id == ocorrencia.id);
    if (i != -1) _itens[i] = ocorrencia;
  }

  @override
  Future<void> delete(int id) async {
    _verificarFalha();
    _itens.removeWhere((o) => o.id == id);
  }
}

Ocorrencia criarOcorrencia({
  int? id,
  String titulo = 'Rua sem iluminação',
  String bairro = 'Centro',
  CategoriaOcorrencia categoria = CategoriaOcorrencia.iluminacao,
  NivelRisco nivelRisco = NivelRisco.medio,
  bool resolvida = false,
  DateTime? dataRegistro,
}) {
  return Ocorrencia(
    id: id,
    titulo: titulo,
    descricao: 'Descrição de teste com tamanho suficiente.',
    categoria: categoria,
    bairro: bairro,
    nivelRisco: nivelRisco,
    periodo: Periodo.noite,
    resolvida: resolvida,
    dataRegistro: dataRegistro ?? DateTime(2026, 11, 1),
  );
}
