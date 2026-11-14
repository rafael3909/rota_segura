import '../models/ocorrencia.dart';
import 'database_helper.dart';

/// Contrato da camada de dados. O Provider depende desta abstração,
/// o que permite trocar o SQLite por um fake nos testes de unidade.
abstract class OcorrenciaRepository {
  Future<List<Ocorrencia>> getAll();
  Future<Ocorrencia> insert(Ocorrencia ocorrencia);
  Future<void> update(Ocorrencia ocorrencia);
  Future<void> delete(int id);
}

/// Implementação com SQLite (sqflite). Todas as operações são assíncronas.
class SqliteOcorrenciaRepository implements OcorrenciaRepository {
  SqliteOcorrenciaRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;

  static const String _table = DatabaseHelper.tableOcorrencias;

  @override
  Future<List<Ocorrencia>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, orderBy: 'data_registro DESC');
    return rows.map(Ocorrencia.fromMap).toList();
  }

  @override
  Future<Ocorrencia> insert(Ocorrencia ocorrencia) async {
    final db = await _dbHelper.database;
    final map = ocorrencia.toMap()..remove('id');
    final id = await db.insert(_table, map);
    return ocorrencia.copyWith(id: id);
  }

  @override
  Future<void> update(Ocorrencia ocorrencia) async {
    final db = await _dbHelper.database;
    await db.update(
      _table,
      ocorrencia.toMap(),
      where: 'id = ?',
      whereArgs: [ocorrencia.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
