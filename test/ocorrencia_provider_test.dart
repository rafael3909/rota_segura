import 'package:flutter_test/flutter_test.dart';
import 'package:rota_segura/models/ocorrencia.dart';
import 'package:rota_segura/providers/ocorrencia_provider.dart';

import 'helpers/fake_ocorrencia_repository.dart';

void main() {
  late FakeOcorrenciaRepository repository;
  late OcorrenciaProvider provider;

  setUp(() {
    repository = FakeOcorrenciaRepository([
      criarOcorrencia(
        id: 1,
        bairro: 'Capão Redondo',
        nivelRisco: NivelRisco.alto,
        dataRegistro: DateTime(2026, 11, 1),
      ),
      criarOcorrencia(
        id: 2,
        bairro: 'Capão Redondo',
        categoria: CategoriaOcorrencia.assalto,
        dataRegistro: DateTime(2026, 11, 5),
      ),
      criarOcorrencia(
        id: 3,
        bairro: 'Butantã',
        categoria: CategoriaOcorrencia.calcada,
        resolvida: true,
        dataRegistro: DateTime(2026, 11, 3),
      ),
    ]);
    provider = OcorrenciaProvider(repository);
  });

  group('OcorrenciaProvider - carregamento', () {
    test('loadOcorrencias carrega, ordena por data e desliga o loading',
        () async {
      final estadosLoading = <bool>[];
      provider.addListener(() => estadosLoading.add(provider.isLoading));

      await provider.loadOcorrencias();

      expect(estadosLoading, [true, false]);
      expect(provider.total, 3);
      expect(provider.ocorrencias.map((o) => o.id), [2, 3, 1]);
      expect(provider.hasError, isFalse);
    });

    test('falha no repositório gera mensagem de erro amigável', () async {
      repository.deveFalhar = true;

      await provider.loadOcorrencias();

      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, contains('Não foi possível'));
      expect(provider.isLoading, isFalse);
      expect(provider.total, 0);
    });
  });

  group('OcorrenciaProvider - CRUD', () {
    setUp(() async => provider.loadOcorrencias());

    test('addOcorrencia insere, recebe id e notifica a UI', () async {
      var notificacoes = 0;
      provider.addListener(() => notificacoes++);

      final ok = await provider.addOcorrencia(
        criarOcorrencia(titulo: 'Novo ponto', dataRegistro: DateTime(2026, 11, 12)),
      );

      expect(ok, isTrue);
      expect(provider.total, 4);
      expect(provider.ocorrencias.first.titulo, 'Novo ponto');
      expect(provider.ocorrencias.first.id, isNotNull);
      expect(notificacoes, 1);
    });

    test('updateOcorrencia substitui o registro existente', () async {
      final original = provider.findById(2)!;

      final ok = await provider
          .updateOcorrencia(original.copyWith(titulo: 'Título editado'));

      expect(ok, isTrue);
      expect(provider.findById(2)!.titulo, 'Título editado');
      expect(provider.total, 3);
    });

    test('updateOcorrencia sem id retorna false', () async {
      final ok = await provider.updateOcorrencia(criarOcorrencia());
      expect(ok, isFalse);
    });

    test('deleteOcorrencia remove o item da lista', () async {
      final ok = await provider.deleteOcorrencia(1);

      expect(ok, isTrue);
      expect(provider.findById(1), isNull);
      expect(provider.total, 2);
    });

    test('erro ao inserir não altera a lista e retorna false', () async {
      repository.deveFalhar = true;

      final ok = await provider.addOcorrencia(criarOcorrencia());

      expect(ok, isFalse);
      expect(provider.total, 3);
    });

    test('alternarResolvida muda o status e atualiza indicadores', () async {
      expect(provider.totalResolvidas, 1);

      await provider.alternarResolvida(provider.findById(1)!);

      expect(provider.findById(1)!.resolvida, isTrue);
      expect(provider.totalResolvidas, 2);
      expect(provider.totalCriticas, 0);
    });
  });

  group('OcorrenciaProvider - indicadores e filtros', () {
    setUp(() async => provider.loadOcorrencias());

    test('calcula totais, críticas e percentual de resolvidas', () {
      expect(provider.totalAbertas, 2);
      expect(provider.totalResolvidas, 1);
      expect(provider.totalCriticas, 1);
      expect(provider.percentualResolvidas, closeTo(1 / 3, 0.001));
      expect(provider.totalPorCategoria[CategoriaOcorrencia.assalto], 1);
    });

    test('bairroMaisCritico considera apenas ocorrências abertas', () async {
      expect(provider.bairroMaisCritico, 'Capão Redondo');

      await provider.alternarResolvida(provider.findById(1)!);
      await provider.alternarResolvida(provider.findById(2)!);

      expect(provider.bairroMaisCritico, isNull);
    });

    test('filtros por categoria e ocultar resolvidas', () {
      provider.setFiltroCategoria(CategoriaOcorrencia.calcada);
      expect(provider.ocorrenciasFiltradas.map((o) => o.id), [3]);

      provider.setOcultarResolvidas(true);
      expect(provider.ocorrenciasFiltradas, isEmpty);
      expect(provider.temFiltroAtivo, isTrue);

      provider.limparFiltros();
      expect(provider.ocorrenciasFiltradas.length, 3);
      expect(provider.temFiltroAtivo, isFalse);
    });

    test('valores iniciais sem dados não quebram os indicadores', () {
      final vazio = OcorrenciaProvider(FakeOcorrenciaRepository());
      expect(vazio.total, 0);
      expect(vazio.percentualResolvidas, 0);
      expect(vazio.bairroMaisCritico, isNull);
    });
  });
}
