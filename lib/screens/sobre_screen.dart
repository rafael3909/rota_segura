import 'package:flutter/material.dart';

import '../widgets/info_row.dart';
import '../widgets/ods_badge.dart';

/// Tela 5 — Sobre o projeto: problema, público-alvo e ODS atendidos.
class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o Rota Segura')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle('O problema'),
          Text(
            'Muitas pessoas voltam para casa a pé, à noite, por ruas escuras, '
            'calçadas quebradas ou pontos conhecidos de assalto e assédio. '
            'Essas informações circulam só no boca a boca e raramente chegam '
            'de forma organizada a quem pode resolver.',
            style: textTheme.bodyLarge,
          ),
          const SectionTitle('A solução'),
          Text(
            'O Rota Segura permite que o cidadão registre pontos inseguros do '
            'seu bairro, classifique o risco e o período mais crítico, e '
            'acompanhe quando o problema foi resolvido. O painel resume os '
            'dados para vizinhos, lideranças comunitárias e subprefeituras.',
            style: textTheme.bodyLarge,
          ),
          const SectionTitle('Para quem'),
          const _Publico(
            icon: Icons.directions_walk,
            texto: 'Pedestres, estudantes e trabalhadores que voltam à noite',
          ),
          const _Publico(
            icon: Icons.groups_outlined,
            texto: 'Associações de moradores e lideranças comunitárias',
          ),
          const _Publico(
            icon: Icons.account_balance_outlined,
            texto: 'Subprefeituras e órgãos de zeladoria e segurança',
          ),
          const SectionTitle('ODS da ONU conectados'),
          for (final ods in Ods.atendidos)
            Card(
              elevation: 0,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: ods.cor,
                  child: Text(
                    '${ods.numero}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                title: Text('ODS ${ods.numero} — ${ods.titulo}'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(ods.contribuicao),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Desafio FIAP CitizenTech • Flutter 2026',
              style: textTheme.bodySmall?.copyWith(color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}

class _Publico extends StatelessWidget {
  const _Publico({required this.icon, required this.texto});

  final IconData icon;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(texto),
    );
  }
}
