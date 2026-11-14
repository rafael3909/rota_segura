import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rota_segura/models/ocorrencia.dart';
import 'package:rota_segura/widgets/risk_badge.dart';
import 'package:rota_segura/widgets/state_views.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('RiskBadge exibe o nível de risco', (tester) async {
    await tester.pumpWidget(_wrap(const RiskBadge(nivel: NivelRisco.alto)));

    expect(find.text('Risco Alto'), findsOneWidget);
  });

  testWidgets('EmptyState mostra mensagem e dispara a ação', (tester) async {
    var clicou = false;
    await tester.pumpWidget(_wrap(EmptyState(
      icon: Icons.add,
      title: 'Nenhuma ocorrência registrada',
      message: 'Seja o primeiro',
      actionLabel: 'Registrar ocorrência',
      onAction: () => clicou = true,
    )));

    expect(find.text('Nenhuma ocorrência registrada'), findsOneWidget);
    await tester.tap(find.text('Registrar ocorrência'));
    expect(clicou, isTrue);
  });
}
