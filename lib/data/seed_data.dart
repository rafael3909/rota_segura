import '../models/ocorrencia.dart';


class SeedData {
  SeedData._();

  static List<Ocorrencia> ocorrencias() {
    final agora = DateTime.now();
    return [
      Ocorrencia(
        titulo: 'Rua inteira sem iluminação',
        descricao:
            'Os postes da rua estão apagados há mais de duas semanas. Quem volta '
            'do trabalho à noite precisa atravessar o trecho no escuro.',
        categoria: CategoriaOcorrencia.iluminacao,
        bairro: 'Capão Redondo',
        referencia: 'Próximo ao ponto de ônibus da Estrada de Itapecerica',
        nivelRisco: NivelRisco.alto,
        periodo: Periodo.noite,
        dataRegistro: agora.subtract(const Duration(hours: 5)),
      ),
      Ocorrencia(
        titulo: 'Assaltos frequentes na saída da estação',
        descricao:
            'Moradores relatam vários assaltos a celular na passarela de saída '
            'da estação, principalmente no início da manhã.',
        categoria: CategoriaOcorrencia.assalto,
        bairro: 'Itaquera',
        referencia: 'Passarela de acesso à estação',
        nivelRisco: NivelRisco.alto,
        periodo: Periodo.madrugada,
        anonima: true,
        dataRegistro: agora.subtract(const Duration(days: 1)),
      ),
      Ocorrencia(
        titulo: 'Calçada com buraco grande',
        descricao:
            'Buraco de quase um metro na calçada obriga pedestres a andar pela '
            'rua. Cadeirantes não conseguem passar.',
        categoria: CategoriaOcorrencia.calcada,
        bairro: 'Butantã',
        referencia: 'Em frente à padaria da esquina',
        nivelRisco: NivelRisco.medio,
        periodo: Periodo.tarde,
        dataRegistro: agora.subtract(const Duration(days: 3)),
      ),
      Ocorrencia(
        titulo: 'Ponto de alagamento na avenida',
        descricao:
            'Em dias de chuva forte a avenida alaga e o trecho fica intransitável '
            'para pedestres e motos.',
        categoria: CategoriaOcorrencia.alagamento,
        bairro: 'Vila Prudente',
        nivelRisco: NivelRisco.medio,
        periodo: Periodo.tarde,
        resolvida: true,
        dataRegistro: agora.subtract(const Duration(days: 9)),
      ),
      Ocorrencia(
        titulo: 'Terreno abandonado sem muro',
        descricao:
            'Terreno com mato alto e sem muro ao lado da escola. Pais pedem '
            'atenção porque crianças passam pelo local todos os dias.',
        categoria: CategoriaOcorrencia.terrenoAbandonado,
        bairro: 'Capão Redondo',
        referencia: 'Ao lado da EMEF do bairro',
        nivelRisco: NivelRisco.baixo,
        periodo: Periodo.manha,
        dataRegistro: agora.subtract(const Duration(days: 15)),
      ),
    ];
  }
}
