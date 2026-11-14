import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../models/ocorrencia.dart';
import '../providers/ocorrencia_provider.dart';
import '../widgets/ocorrencia_actions.dart';
import '../widgets/ocorrencia_card.dart';
import '../widgets/state_views.dart';

/// Tela 2 — Listagem dinâmica com ListView.separated.
class OcorrenciaListScreen extends StatelessWidget {
  const OcorrenciaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ocultar = context.select<OcorrenciaProvider, bool>(
      (p) => p.ocultarResolvidas,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocorrências'),
        actions: [
          IconButton(
            tooltip: ocultar ? 'Mostrar resolvidas' : 'Ocultar resolvidas',
            icon: Icon(ocultar
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
            onPressed: () => context
                .read<OcorrenciaProvider>()
                .setOcultarResolvidas(!ocultar),
          ),
          IconButton(
            tooltip: 'Recarregar',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<OcorrenciaProvider>().loadOcorrencias(),
          ),
        ],
      ),
      body: const Column(
        children: [
          _FiltroCategorias(),
          Expanded(child: _ListaBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova ocorrência',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.formulario),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FiltroCategorias extends StatelessWidget {
  const _FiltroCategorias();

  @override
  Widget build(BuildContext context) {
    final selecionada = context.select<OcorrenciaProvider, CategoriaOcorrencia?>(
      (p) => p.filtroCategoria,
    );
    final provider = context.read<OcorrenciaProvider>();

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Todas'),
              selected: selecionada == null,
              onSelected: (_) => provider.setFiltroCategoria(null),
            ),
          ),
          for (final categoria in CategoriaOcorrencia.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(categoria.icon, size: 18),
                label: Text(categoria.label),
                selected: selecionada == categoria,
                onSelected: (_) => provider.setFiltroCategoria(categoria),
              ),
            ),
        ],
      ),
    );
  }
}

class _ListaBody extends StatelessWidget {
  const _ListaBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<OcorrenciaProvider>(
      builder: (context, provider, _) {
        // 1) Carregando
        if (provider.isLoading && provider.total == 0) {
          return const LoadingView(message: 'Carregando ocorrências...');
        }

        // 2) Erro
        if (provider.hasError) {
          return ErrorState(
            message: provider.errorMessage!,
            onRetry: provider.loadOcorrencias,
          );
        }

        final itens = provider.ocorrenciasFiltradas;

        // 3) Lista vazia
        if (itens.isEmpty) {
          if (provider.total == 0) {
            return EmptyState(
              icon: Icons.add_location_alt_outlined,
              title: 'Nenhuma ocorrência registrada',
              message:
                  'Seja o primeiro a apontar um ponto inseguro no seu bairro.',
              actionLabel: 'Registrar ocorrência',
              onAction: () =>
                  Navigator.pushNamed(context, AppRoutes.formulario),
            );
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_alt_off_outlined,
                    size: 64, color: Colors.black26),
                const SizedBox(height: 12),
                const Text('Nenhuma ocorrência para este filtro.'),
                TextButton(
                  onPressed: provider.limparFiltros,
                  child: const Text('Limpar filtros'),
                ),
              ],
            ),
          );
        }

        // 4) Lista com dados
        return RefreshIndicator(
          onRefresh: provider.loadOcorrencias,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
            itemCount: itens.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final ocorrencia = itens[index];
              return OcorrenciaCard(
                key: ValueKey(ocorrencia.id),
                ocorrencia: ocorrencia,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.detalhes,
                  arguments: ocorrencia.id,
                ),
                onAcao: (acao) => _executarAcao(context, acao, ocorrencia),
              );
            },
          ),
        );
      },
    );
  }

  void _executarAcao(
      BuildContext context, AcaoRapida acao, Ocorrencia ocorrencia) {
    switch (acao) {
      case AcaoRapida.editar:
        Navigator.pushNamed(context, AppRoutes.formulario,
            arguments: ocorrencia);
      case AcaoRapida.alternarStatus:
        alternarStatus(context, ocorrencia);
      case AcaoRapida.excluir:
        confirmarExclusao(context, ocorrencia);
    }
  }
}
