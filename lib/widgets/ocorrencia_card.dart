import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/date_utils.dart';
import '../models/ocorrencia.dart';
import 'risk_badge.dart';

enum AcaoRapida { editar, alternarStatus, excluir }

/// Item da listagem de ocorrências, com menu de ações rápidas.
class OcorrenciaCard extends StatelessWidget {
  const OcorrenciaCard({
    super.key,
    required this.ocorrencia,
    required this.onTap,
    required this.onAcao,
  });

  final Ocorrencia ocorrencia;
  final VoidCallback onTap;
  final ValueChanged<AcaoRapida> onAcao;

  @override
  Widget build(BuildContext context) {
    final o = ocorrencia;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: o.isCritica ? AppColors.riscoAlto.withAlpha(90) : Colors.black12,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: o.nivelRisco.color.withAlpha(30),
                child: Icon(o.categoria.icon, color: o.nivelRisco.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        decoration:
                            o.resolvida ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 14, color: Colors.black54),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${o.bairro} • ${tempoDecorrido(o.dataRegistro)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall
                                ?.copyWith(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        RiskBadge(nivel: o.nivelRisco),
                        StatusBadge(resolvida: o.resolvida),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<AcaoRapida>(
                tooltip: 'Ações',
                icon: const Icon(Icons.more_vert),
                onSelected: onAcao,
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: AcaoRapida.editar,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: AcaoRapida.alternarStatus,
                    child: ListTile(
                      leading: Icon(o.resolvida ? Icons.undo : Icons.done_all),
                      title: Text(o.resolvida
                          ? 'Reabrir ocorrência'
                          : 'Marcar como resolvida'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: AcaoRapida.excluir,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Excluir',
                          style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
