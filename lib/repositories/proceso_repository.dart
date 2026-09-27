import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/proceso.dart';

class ProcesoRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insertar(Proceso proceso) async {
    final db = await _databaseHelper.database;

    return db.insert(
      'procesos',
      proceso.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<Proceso?> obtenerPorLote(int loteId) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'procesos',
      where: 'lote_id = ?',
      whereArgs: [loteId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Proceso.fromMap(maps.first);
  }

  Future<List<Proceso>> obtenerTodos() async {
    final db = await _databaseHelper.database;

    final maps = await db.query('procesos', orderBy: 'id DESC');

    return maps.map(Proceso.fromMap).toList();
  }

  Future<int> actualizar(Proceso proceso) async {
    if (proceso.id == null) {
      throw ArgumentError('El proceso debe tener un id para actualizarse.');
    }

    final db = await _databaseHelper.database;

    return db.update(
      'procesos',
      proceso.toMap(),
      where: 'id = ?',
      whereArgs: [proceso.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _databaseHelper.database;

    return db.delete('procesos', where: 'id = ?', whereArgs: [id]);
  }
}
