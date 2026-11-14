import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Um Objetivo de Desenvolvimento Sustentável atendido pelo app.
class Ods {
  const Ods(this.numero, this.titulo, this.cor, this.contribuicao);

  final int numero;
  final String titulo;
  final Color cor;
  final String contribuicao;

  static const List<Ods> atendidos = [
    Ods(
      11,
      'Cidades e comunidades sustentáveis',
      AppColors.ods11,
      'Mapeia pontos inseguros para tornar os deslocamentos urbanos mais '
          'seguros e orientar a zeladoria pública.',
    ),
    Ods(
      16,
      'Paz, justiça e instituições eficazes',
      AppColors.ods16,
      'Dá visibilidade a locais de violência e ajuda o poder público a '
          'priorizar ações de segurança com dados do cidadão.',
    ),
    Ods(
      10,
      'Redução das desigualdades',
      AppColors.ods10,
      'Dá voz a bairros periféricos, que costumam ter menos iluminação, '
          'policiamento e infraestrutura.',
    ),
  ];
}

/// Selo compacto "ODS 11" usado no dashboard.
class OdsBadge extends StatelessWidget {
  const OdsBadge({super.key, required this.ods});

  final Ods ods;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: ods.titulo,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: ods.cor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ODS ${ods.numero}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                ods.titulo,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
