import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'seed_data.dart';


class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String databaseName = 'rota_segura.db';
  static const int databaseVersion = 1;
  static const String tableOcorrencias = 'ocorrencias';

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), databaseName);
    return openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableOcorrencias (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo        TEXT    NOT NULL,
        descricao     TEXT    NOT NULL,
        categoria     TEXT    NOT NULL,
        bairro        TEXT    NOT NULL,
        referencia    TEXT,
        nivel_risco   INTEGER NOT NULL,
        periodo       TEXT    NOT NULL,
        resolvida     INTEGER NOT NULL DEFAULT 0,
        anonima       INTEGER NOT NULL DEFAULT 0,
        data_registro TEXT    NOT NULL
      )
    ''');

    final batch = db.batch();
    for (final ocorrencia in SeedData.ocorrencias()) {
      batch.insert(tableOcorrencias, ocorrencia.toMap());
    }
    await batch.commit(noResult: true);
  }
}
