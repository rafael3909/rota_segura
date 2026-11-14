import 'package:flutter_test/flutter_test.dart';
import 'package:rota_segura/core/utils/date_utils.dart';
import 'package:rota_segura/core/utils/validators.dart';
import 'package:rota_segura/models/ocorrencia.dart';

void main() {
  group('OcorrenciaValidators', () {
    test('título: rejeita vazio, curto e longo; aceita válido', () {
      expect(OcorrenciaValidators.titulo(null), isNotNull);
      expect(OcorrenciaValidators.titulo('   '), isNotNull);
      expect(OcorrenciaValidators.titulo('Rua'), isNotNull);
      expect(OcorrenciaValidators.titulo('a' * 61), isNotNull);
      expect(OcorrenciaValidators.titulo('Rua sem iluminação'), isNull);
    });

    test('descrição: exige ao menos 15 caracteres', () {
      expect(OcorrenciaValidators.descricao(''), isNotNull);
      expect(OcorrenciaValidators.descricao('Muito escuro'), isNotNull);
      expect(
        OcorrenciaValidators.descricao('Os postes estão apagados há dias.'),
        isNull,
      );
    });

    test('bairro: obrigatório e precisa conter letras', () {
      expect(OcorrenciaValidators.bairro(''), isNotNull);
      expect(OcorrenciaValidators.bairro('12345'), isNotNull);
      expect(OcorrenciaValidators.bairro('Sé'), isNotNull);
      expect(OcorrenciaValidators.bairro('Capão Redondo'), isNull);
    });

    test('referência é opcional, mas limitada a 120 caracteres', () {
      expect(OcorrenciaValidators.referencia(null), isNull);
      expect(OcorrenciaValidators.referencia(''), isNull);
      expect(OcorrenciaValidators.referencia('x' * 121), isNotNull);
    });

    test('selects e confirmação são obrigatórios', () {
      expect(OcorrenciaValidators.categoria(null), isNotNull);
      expect(
          OcorrenciaValidators.categoria(CategoriaOcorrencia.assedio), isNull);
      expect(OcorrenciaValidators.periodo(null), isNotNull);
      expect(OcorrenciaValidators.periodo(Periodo.tarde), isNull);
      expect(OcorrenciaValidators.confirmacao(false), isNotNull);
      expect(OcorrenciaValidators.confirmacao(null), isNotNull);
      expect(OcorrenciaValidators.confirmacao(true), isNull);
    });
  });

  group('date_utils', () {
    test('formatarDataHora usa o padrão brasileiro', () {
      expect(formatarDataHora(DateTime(2026, 3, 5, 7, 9)), '05/03/2026 às 07:09');
    });

    test('tempoDecorrido gera textos relativos', () {
      final agora = DateTime(2026, 11, 13, 20);
      expect(tempoDecorrido(agora, agora: agora), 'agora mesmo');
      expect(
        tempoDecorrido(agora.subtract(const Duration(minutes: 15)),
            agora: agora),
        'há 15 min',
      );
      expect(
        tempoDecorrido(agora.subtract(const Duration(hours: 3)), agora: agora),
        'há 3 h',
      );
      expect(
        tempoDecorrido(agora.subtract(const Duration(days: 4)), agora: agora),
        'há 4 dias',
      );
    });
  });
}
