import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/fotografia.dart';

class FotografiaRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insertar(Fotografia fotografia) async {
    final db = await _databaseHelper.database;

    return db.insert(
      'fotografias',
      fotografia.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Fotografia>> obtenerTodas() async {
    final db = await _databaseHelper.database;

    final maps = await db.query('fotografias', orderBy: 'id DESC');

    return maps.map(Fotografia.fromMap).toList();
  }

  Future<List<Fotografia>> obtenerPorLote(int loteId) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'fotografias',
      where: 'lote_id = ?',
      whereArgs: [loteId],
      orderBy: 'id DESC',
    );

    return maps.map(Fotografia.fromMap).toList();
  }

  Future<int> actualizar(Fotografia fotografia) async {
    if (fotografia.id == null) {
      throw ArgumentError('La fotografía debe tener un id para actualizarse.');
    }

    final db = await _databaseHelper.database;

    return db.update(
      'fotografias',
      fotografia.toMap(),
      where: 'id = ?',
      whereArgs: [fotografia.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _databaseHelper.database;

    return db.delete('fotografias', where: 'id = ?', whereArgs: [id]);
  }
}
