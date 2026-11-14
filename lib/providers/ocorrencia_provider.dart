import 'package:flutter/foundation.dart';

import '../data/ocorrencia_repository.dart';
import '../models/ocorrencia.dart';

/// Estado global das ocorrências. A UI só lê daqui (watch/Consumer) e
/// chama os métodos (read); nenhuma tela acessa o banco diretamente.
class OcorrenciaProvider extends ChangeNotifier {
  OcorrenciaProvider(this._repository);

  final OcorrenciaRepository _repository;

  List<Ocorrencia> _ocorrencias = [];
  bool _isLoading = false;
  String? _errorMessage;
  CategoriaOcorrencia? _filtroCategoria;
  bool _ocultarResolvidas = false;

  // ---------------------------------------------------------------- getters

  List<Ocorrencia> get ocorrencias => List.unmodifiable(_ocorrencias);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  CategoriaOcorrencia? get filtroCategoria => _filtroCategoria;
  bool get ocultarResolvidas => _ocultarResolvidas;
  bool get temFiltroAtivo => _filtroCategoria != null || _ocultarResolvidas;

  /// Lista exibida na tela de listagem, já com os filtros aplicados.
  List<Ocorrencia> get ocorrenciasFiltradas {
    return _ocorrencias.where((o) {
      final categoriaOk =
          _filtroCategoria == null || o.categoria == _filtroCategoria;
      final statusOk = !_ocultarResolvidas || !o.resolvida;
      return categoriaOk && statusOk;
    }).toList(growable: false);
  }

  // ------------------------------------------------------------ indicadores

  int get total => _ocorrencias.length;
  int get totalAbertas => _ocorrencias.where((o) => !o.resolvida).length;
  int get totalResolvidas => _ocorrencias.where((o) => o.resolvida).length;
  int get totalCriticas => _ocorrencias.where((o) => o.isCritica).length;

  double get percentualResolvidas => total == 0 ? 0 : totalResolvidas / total;

  Map<CategoriaOcorrencia, int> get totalPorCategoria {
    final mapa = <CategoriaOcorrencia, int>{};
    for (final o in _ocorrencias) {
      mapa[o.categoria] = (mapa[o.categoria] ?? 0) + 1;
    }
    return mapa;
  }

  /// Bairro com mais ocorrências ainda abertas. Empate: ordem alfabética.
  String? get bairroMaisCritico {
    final contagem = <String, int>{};
    for (final o in _ocorrencias.where((o) => !o.resolvida)) {
      final bairro = o.bairro.trim();
      contagem[bairro] = (contagem[bairro] ?? 0) + 1;
    }
    if (contagem.isEmpty) return null;
    final bairros = contagem.keys.toList()
      ..sort((a, b) {
        final porQuantidade = contagem[b]!.compareTo(contagem[a]!);
        return porQuantidade != 0 ? porQuantidade : a.compareTo(b);
      });
    return bairros.first;
  }

  Ocorrencia? findById(int id) {
    for (final o in _ocorrencias) {
      if (o.id == id) return o;
    }
    return null;
  }

  // ------------------------------------------------------------------ CRUD

  Future<void> loadOcorrencias() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ocorrencias = List.of(await _repository.getAll());
      _ordenar();
    } catch (e) {
      _errorMessage =
          'Não foi possível carregar as ocorrências. Tente novamente.';
      debugPrint('Erro ao carregar ocorrências: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addOcorrencia(Ocorrencia ocorrencia) async {
    try {
      final salva = await _repository.insert(ocorrencia);
      _ocorrencias.add(salva);
      _ordenar();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao inserir ocorrência: $e');
      return false;
    }
  }

  Future<bool> updateOcorrencia(Ocorrencia ocorrencia) async {
    final id = ocorrencia.id;
    if (id == null) return false;
    try {
      await _repository.update(ocorrencia);
      final index = _ocorrencias.indexWhere((o) => o.id == id);
      if (index != -1) {
        _ocorrencias[index] = ocorrencia;
        _ordenar();
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar ocorrência: $e');
      return false;
    }
  }

  Future<bool> deleteOcorrencia(int id) async {
    try {
      await _repository.delete(id);
      _ocorrencias.removeWhere((o) => o.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao excluir ocorrência: $e');
      return false;
    }
  }

  Future<bool> alternarResolvida(Ocorrencia ocorrencia) {
    return updateOcorrencia(ocorrencia.copyWith(resolvida: !ocorrencia.resolvida));
  }

  // --------------------------------------------------------------- filtros

  void setFiltroCategoria(CategoriaOcorrencia? categoria) {
    _filtroCategoria = categoria;
    notifyListeners();
  }

  void setOcultarResolvidas(bool valor) {
    _ocultarResolvidas = valor;
    notifyListeners();
  }

  void limparFiltros() {
    _filtroCategoria = null;
    _ocultarResolvidas = false;
    notifyListeners();
  }

  void _ordenar() {
    _ocorrencias.sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));
  }
}
