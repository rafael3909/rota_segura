import '../../models/ocorrencia.dart';

/// Regras de validação do formulário, isoladas da UI para poderem
/// ser testadas com `flutter test`.
class OcorrenciaValidators {
  OcorrenciaValidators._();

  static final RegExp _temLetra = RegExp(r'[A-Za-zÀ-ÿ]');

  static String? titulo(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Informe um título para a ocorrência.';
    if (texto.length < 5) return 'O título deve ter pelo menos 5 caracteres.';
    if (texto.length > 60) return 'O título deve ter no máximo 60 caracteres.';
    return null;
  }

  static String? descricao(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Descreva o que está acontecendo no local.';
    if (texto.length < 15) {
      return 'Detalhe um pouco mais (mínimo de 15 caracteres).';
    }
    if (texto.length > 500) {
      return 'A descrição deve ter no máximo 500 caracteres.';
    }
    return null;
  }

  static String? bairro(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Informe o bairro.';
    if (texto.length < 3) return 'Nome de bairro muito curto.';
    if (!_temLetra.hasMatch(texto)) return 'Informe um nome de bairro válido.';
    return null;
  }

  /// Campo opcional: só valida o tamanho quando preenchido.
  static String? referencia(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.length > 120) {
      return 'O ponto de referência deve ter no máximo 120 caracteres.';
    }
    return null;
  }

  static String? categoria(CategoriaOcorrencia? value) {
    return value == null ? 'Selecione uma categoria.' : null;
  }

  static String? periodo(Periodo? value) {
    return value == null ? 'Selecione o período em que ocorre.' : null;
  }

  static String? confirmacao(bool? value) {
    return value == true
        ? null
        : 'Confirme que as informações são verdadeiras.';
  }
}
