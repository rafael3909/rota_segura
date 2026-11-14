import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/ocorrencia.dart';

/// Etiqueta colorida com o nível de risco da ocorrência.
class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.nivel});

  final NivelRisco nivel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Risco ${nivel.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: nivel.color.withAlpha(28),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: nivel.color.withAlpha(120)),
        ),
        child: Text(
          'Risco ${nivel.label}',
          style: TextStyle(
            color: nivel.color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// Etiqueta de status (Aberta / Resolvida).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.resolvida});

  final bool resolvida;

  @override
  Widget build(BuildContext context) {
    final color = resolvida ? AppColors.resolvida : Colors.blueGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            resolvida ? Icons.check_circle : Icons.pending_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            resolvida ? 'Resolvida' : 'Aberta',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
