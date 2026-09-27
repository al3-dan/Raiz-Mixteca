import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/lote.dart';

class LoteRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insertar(Lote lote) async {
    final db = await _databaseHelper.database;

    return db.insert(
      'lotes',
      lote.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Lote>> obtenerTodos() async {
    final db = await _databaseHelper.database;

    final maps = await db.query('lotes', orderBy: 'id DESC');

    return maps.map(Lote.fromMap).toList();
  }

  Future<List<Lote>> obtenerPorProducto(int productoId) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'lotes',
      where: 'producto_id = ?',
      whereArgs: [productoId],
      orderBy: 'id DESC',
    );

    return maps.map(Lote.fromMap).toList();
  }

  Future<Lote?> obtenerPorId(int id) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'lotes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Lote.fromMap(maps.first);
  }

  Future<int> actualizar(Lote lote) async {
    if (lote.id == null) {
      throw ArgumentError('El lote debe tener un id para actualizarse.');
    }

    final db = await _databaseHelper.database;

    return db.update(
      'lotes',
      lote.toMap(),
      where: 'id = ?',
      whereArgs: [lote.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _databaseHelper.database;

    return db.delete('lotes', where: 'id = ?', whereArgs: [id]);
  }
}
