import 'package:flutter_test/flutter_test.dart';
import 'package:rota_segura/models/ocorrencia.dart';

void main() {
  group('Ocorrencia (model)', () {
    final base = Ocorrencia(
      id: 7,
      titulo: 'Assaltos na passarela',
      descricao: 'Vários relatos de assalto no início da manhã.',
      categoria: CategoriaOcorrencia.assalto,
      bairro: 'Itaquera',
      referencia: 'Saída da estação',
      nivelRisco: NivelRisco.alto,
      periodo: Periodo.madrugada,
      resolvida: false,
      anonima: true,
      dataRegistro: DateTime(2026, 11, 10, 6, 30),
    );

    test('toMap e fromMap preservam todos os campos (ida e volta)', () {
      final map = base.toMap();
      final restaurada = Ocorrencia.fromMap(map);

      expect(restaurada.id, 7);
      expect(restaurada.titulo, base.titulo);
      expect(restaurada.categoria, CategoriaOcorrencia.assalto);
      expect(restaurada.nivelRisco, NivelRisco.alto);
      expect(restaurada.periodo, Periodo.madrugada);
      expect(restaurada.referencia, 'Saída da estação');
      expect(restaurada.anonima, isTrue);
      expect(restaurada.dataRegistro, base.dataRegistro);
    });

    test('toMap grava booleanos como 0/1 e omite id nulo', () {
      final semId = base.copyWith(resolvida: true).toMap()..remove('id');
      final novo = Ocorrencia.fromMap({...semId});

      expect(semId['resolvida'], 1);
      expect(semId['anonima'], 1);
      expect(semId['nivel_risco'], 3);
      expect(novo.id, isNull);

      final mapaNovo = Ocorrencia(
        titulo: 't',
        descricao: 'd',
        categoria: CategoriaOcorrencia.outro,
        bairro: 'b',
        nivelRisco: NivelRisco.baixo,
        periodo: Periodo.tarde,
        dataRegistro: DateTime(2026),
      ).toMap();
      expect(mapaNovo.containsKey('id'), isFalse);
      expect(mapaNovo['resolvida'], 0);
    });

    test('copyWith altera só os campos informados', () {
      final editada = base.copyWith(titulo: 'Novo título', resolvida: true);

      expect(editada.titulo, 'Novo título');
      expect(editada.resolvida, isTrue);
      expect(editada.id, base.id);
      expect(editada.bairro, base.bairro);
      expect(editada.categoria, base.categoria);
    });

    test('isCritica só é verdadeiro para risco alto e não resolvida', () {
      expect(base.isCritica, isTrue);
      expect(base.copyWith(resolvida: true).isCritica, isFalse);
      expect(base.copyWith(nivelRisco: NivelRisco.medio).isCritica, isFalse);
    });

    test('enums usam valor padrão para dados desconhecidos no banco', () {
      expect(CategoriaOcorrencia.fromName('inexistente'),
          CategoriaOcorrencia.outro);
      expect(CategoriaOcorrencia.fromName(null), CategoriaOcorrencia.outro);
      expect(NivelRisco.fromValor(99), NivelRisco.medio);
      expect(NivelRisco.fromValor(1), NivelRisco.baixo);
      expect(Periodo.fromName('xyz'), Periodo.noite);
      expect(Periodo.fromName('manha'), Periodo.manha);
    });
  });
}
