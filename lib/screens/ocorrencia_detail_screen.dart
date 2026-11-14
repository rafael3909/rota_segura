import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_utils.dart';
import '../models/ocorrencia.dart';
import '../providers/ocorrencia_provider.dart';
import '../widgets/info_row.dart';
import '../widgets/ocorrencia_actions.dart';
import '../widgets/risk_badge.dart';

/// Tela 4 — Detalhes do registro.
///
/// Recebe o [ocorrenciaId] pela rota e busca o item no Provider, então
/// qualquer edição feita no formulário aparece aqui automaticamente.
class OcorrenciaDetailScreen extends StatelessWidget {
  const OcorrenciaDetailScreen({super.key, required this.ocorrenciaId});

  final int ocorrenciaId;

  Future<void> _excluir(BuildContext context, Ocorrencia o) async {
    final excluida = await confirmarExclusao(context, o);
    if (excluida && context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ocorrencia = context.select<OcorrenciaProvider, Ocorrencia?>(
      (p) => p.findById(ocorrenciaId),
    );

    if (ocorrencia == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes')),
        body: const Center(child: Text('Ocorrência não encontrada.')),
      );
    }

    final o = ocorrencia;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da ocorrência'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
                context, AppRoutes.formulario,
                arguments: o),
          ),
          IconButton(
            tooltip: 'Excluir',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _excluir(context, o),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cabeçalho
          Card(
            elevation: 0,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: o.nivelRisco.color.withAlpha(30),
                    child: Icon(o.categoria.icon,
                        color: o.nivelRisco.color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.titulo, style: textTheme.titleLarge),
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
                ],
              ),
            ),
          ),
          if (o.isCritica)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.riscoAlto.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.riscoAlto),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ponto crítico: evite o local no período indicado ou '
                      'procure um caminho alternativo.',
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          const SectionTitle('Descrição'),
          Text(o.descricao, style: textTheme.bodyLarge),
          const SizedBox(height: 8),
          const SectionTitle('Informações'),
          InfoRow(
            icon: Icons.category_outlined,
            label: 'Categoria',
            value: o.categoria.label,
          ),
          InfoRow(
            icon: Icons.location_city,
            label: 'Bairro',
            value: o.bairro,
          ),
          InfoRow(
            icon: Icons.place_outlined,
            label: 'Ponto de referência',
            value: o.referencia ?? 'Não informado',
          ),
          InfoRow(
            icon: Icons.schedule,
            label: 'Período mais crítico',
            value: o.periodo.label,
          ),
          InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Registrada em',
            value: formatarDataHora(o.dataRegistro),
          ),
          InfoRow(
            icon: o.anonima ? Icons.person_off_outlined : Icons.person_outline,
            label: 'Autoria',
            value: o.anonima ? 'Relato anônimo' : 'Relato identificado',
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () => alternarStatus(context, o),
            icon: Icon(o.resolvida ? Icons.undo : Icons.done_all),
            label: Text(
                o.resolvida ? 'Reabrir ocorrência' : 'Marcar como resolvida'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                      context, AppRoutes.formulario,
                      arguments: o),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => _excluir(context, o),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Excluir'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
