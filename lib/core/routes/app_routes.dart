import 'package:flutter/material.dart';

import '../../models/ocorrencia.dart';
import '../../screens/home_screen.dart';
import '../../screens/ocorrencia_detail_screen.dart';
import '../../screens/ocorrencia_form_screen.dart';
import '../../screens/ocorrencia_list_screen.dart';
import '../../screens/sobre_screen.dart';

/// Rotas nomeadas do app, com passagem de argumentos tipados.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String lista = '/ocorrencias';
  static const String formulario = '/ocorrencias/formulario';
  static const String detalhes = '/ocorrencias/detalhes';
  static const String sobre = '/sobre';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );

      case lista:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OcorrenciaListScreen(),
        );

      case formulario:
        // Argumento opcional: ocorrência a ser editada (null = novo cadastro).
        final args = settings.arguments;
        final ocorrencia = args is Ocorrencia ? args : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OcorrenciaFormScreen(ocorrencia: ocorrencia),
        );

      case detalhes:
        // Argumento obrigatório: id da ocorrência selecionada.
        final args = settings.arguments;
        if (args is int) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => OcorrenciaDetailScreen(ocorrenciaId: args),
          );
        }
        return _rotaInvalida(settings);

      case sobre:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SobreScreen(),
        );

      default:
        return _rotaInvalida(settings);
    }
  }

  static Route<dynamic> _rotaInvalida(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Página não encontrada')),
        body: Center(child: Text('Rota inválida: ${settings.name}')),
      ),
    );
  }
}
