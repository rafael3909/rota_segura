import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../providers/ocorrencia_provider.dart';
import '../widgets/info_row.dart';
import '../widgets/ods_badge.dart';
import '../widgets/stat_card.dart';

/// Tela 1 — Home / Dashboard CitizenTech.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega os dados depois do primeiro frame, evitando notificar
    // listeners durante o build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<OcorrenciaProvider>().loadOcorrencias();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined),
            SizedBox(width: 8),
            Text('Rota Segura'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sobre o projeto e ODS',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.sobre),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<OcorrenciaProvider>().loadOcorrencias(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: const [
            _HeroBanner(),
            SizedBox(height: 16),
            _OdsSection(),
            SizedBox(height: 8),
            SectionTitle('Panorama da sua região'),
            _IndicadoresSection(),
            SizedBox(height: 16),
            _AcessosRapidos(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.formulario),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Nova ocorrência'),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF2C7DA0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caminhos mais seguros começam com você',
                  style: textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Registre ruas escuras, locais de assalto e outros pontos '
                  'de risco do seu bairro. Os dados ajudam vizinhos e o poder '
                  'público a agir.',
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.map_outlined, size: 56, color: Colors.white),
        ],
      ),
    );
  }
}

class _OdsSection extends StatelessWidget {
  const _OdsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('ODS da ONU atendidos'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final ods in Ods.atendidos) OdsBadge(ods: ods),
          ],
        ),
      ],
    );
  }
}

class _IndicadoresSection extends StatelessWidget {
  const _IndicadoresSection();

  @override
  Widget build(BuildContext context) {
    // Reage automaticamente a inserções, edições e exclusões.
    final provider = context.watch<OcorrenciaProvider>();

    if (provider.isLoading && provider.total == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    void abrirLista() => Navigator.pushNamed(context, AppRoutes.lista);

    final bairro = provider.bairroMaisCritico;
    final percentual = (provider.percentualResolvidas * 100).round();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.list_alt,
                label: 'Total de registros',
                value: '${provider.total}',
                color: AppColors.primary,
                onTap: abrirLista,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.pending_actions,
                label: 'Em aberto',
                value: '${provider.totalAbertas}',
                color: AppColors.riscoMedio,
                onTap: abrirLista,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.check_circle_outline,
                label: 'Resolvidas',
                value: '${provider.totalResolvidas}',
                color: AppColors.resolvida,
                onTap: abrirLista,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.warning_amber_rounded,
                label: 'Críticas (risco alto)',
                value: '${provider.totalCriticas}',
                color: AppColors.riscoAlto,
                onTap: abrirLista,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_city, color: AppColors.riscoAlto),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bairro == null
                            ? 'Nenhum bairro com alertas em aberto'
                            : 'Bairro com mais alertas: $bairro',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('$percentual% das ocorrências já foram resolvidas'),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: provider.percentualResolvidas,
                    minHeight: 10,
                    color: AppColors.resolvida,
                    backgroundColor: Colors.black12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AcessosRapidos extends StatelessWidget {
  const _AcessosRapidos();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.lista),
            icon: const Icon(Icons.list_alt),
            label: const Text('Ver ocorrências'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.formulario),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Registrar'),
          ),
        ),
      ],
    );
  }
}
