import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/database_helper.dart';
import 'data/ocorrencia_repository.dart';
import 'providers/ocorrencia_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        Provider<OcorrenciaRepository>(
          create: (_) => SqliteOcorrenciaRepository(DatabaseHelper.instance),
        ),
        ChangeNotifierProvider<OcorrenciaProvider>(
          create: (context) =>
              OcorrenciaProvider(context.read<OcorrenciaRepository>()),
        ),
      ],
      child: const RotaSeguraApp(),
    ),
  );
}
