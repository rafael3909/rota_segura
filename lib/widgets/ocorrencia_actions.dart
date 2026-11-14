import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ocorrencia.dart';
import '../providers/ocorrencia_provider.dart';

/// Diálogo de confirmação reutilizável. Retorna `true` se confirmado.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(dialogContext).colorScheme.error,
                )
              : null,
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showAppSnackBar(BuildContext context, String message,
    {bool erro = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: erro ? Theme.of(context).colorScheme.error : null,
    ),
  );
}

/// Pede confirmação e exclui a ocorrência via Provider.
/// Retorna `true` quando a exclusão foi concluída.
Future<bool> confirmarExclusao(
    BuildContext context, Ocorrencia ocorrencia) async {
  final id = ocorrencia.id;
  if (id == null) return false;

  final confirmado = await showConfirmDialog(
    context,
    title: 'Excluir ocorrência?',
    message:
        '"${ocorrencia.titulo}" será removida permanentemente. Esta ação não pode ser desfeita.',
    confirmLabel: 'Excluir',
    destructive: true,
  );
  if (!confirmado || !context.mounted) return false;

  final ok = await context.read<OcorrenciaProvider>().deleteOcorrencia(id);
  if (context.mounted) {
    showAppSnackBar(
      context,
      ok ? 'Ocorrência excluída.' : 'Não foi possível excluir a ocorrência.',
      erro: !ok,
    );
  }
  return ok;
}

/// Alterna entre Aberta/Resolvida e mostra feedback.
Future<void> alternarStatus(BuildContext context, Ocorrencia ocorrencia) async {
  final ok =
      await context.read<OcorrenciaProvider>().alternarResolvida(ocorrencia);
  if (!context.mounted) return;
  if (!ok) {
    showAppSnackBar(context, 'Não foi possível atualizar o status.', erro: true);
    return;
  }
  showAppSnackBar(
    context,
    ocorrencia.resolvida
        ? 'Ocorrência reaberta.'
        : 'Ocorrência marcada como resolvida.',
  );
}
