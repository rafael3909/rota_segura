import 'package:flutter/material.dart';

import '../../models/ocorrencia.dart';

/// Paleta e tipografia padronizadas do app.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1B4965);
  static const Color secondary = Color(0xFF62B6CB);
  static const Color riscoBaixo = Color(0xFF2E7D32);
  static const Color riscoMedio = Color(0xFFEF8F00);
  static const Color riscoAlto = Color(0xFFC62828);
  static const Color resolvida = Color(0xFF2E7D32);

  // Cores oficiais dos ODS da ONU usados no app
  static const Color ods10 = Color(0xFFDD1367);
  static const Color ods11 = Color(0xFFFD9D24);
  static const Color ods16 = Color(0xFF00689D);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Decoração padrão dos campos do formulário.
  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

/// Aparência (ícone/cor) de cada enum de domínio — mantida fora do model
/// para que a camada de domínio não dependa do Flutter.
extension CategoriaVisual on CategoriaOcorrencia {
  IconData get icon {
    switch (this) {
      case CategoriaOcorrencia.iluminacao:
        return Icons.lightbulb_outline;
      case CategoriaOcorrencia.assalto:
        return Icons.warning_amber_rounded;
      case CategoriaOcorrencia.assedio:
        return Icons.record_voice_over_outlined;
      case CategoriaOcorrencia.calcada:
        return Icons.directions_walk;
      case CategoriaOcorrencia.alagamento:
        return Icons.water_drop_outlined;
      case CategoriaOcorrencia.terrenoAbandonado:
        return Icons.home_work_outlined;
      case CategoriaOcorrencia.outro:
        return Icons.more_horiz;
    }
  }
}

extension RiscoVisual on NivelRisco {
  Color get color {
    switch (this) {
      case NivelRisco.baixo:
        return AppColors.riscoBaixo;
      case NivelRisco.medio:
        return AppColors.riscoMedio;
      case NivelRisco.alto:
        return AppColors.riscoAlto;
    }
  }
}
