import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/producto.dart';

class ProductoRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insertar(Producto producto) async {
    final db = await _databaseHelper.database;

    return db.insert(
      'productos',
      producto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Producto>> obtenerTodos() async {
    final db = await _databaseHelper.database;

    final maps = await db.query('productos', orderBy: 'id DESC');

    return maps.map(Producto.fromMap).toList();
  }

  Future<List<Producto>> obtenerPorProductor(int productorId) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'productos',
      where: 'productor_id = ?',
      whereArgs: [productorId],
      orderBy: 'id DESC',
    );

    return maps.map(Producto.fromMap).toList();
  }

  Future<Producto?> obtenerPorId(int id) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Producto.fromMap(maps.first);
  }

  Future<int> actualizar(Producto producto) async {
    if (producto.id == null) {
      throw ArgumentError('El producto debe tener un id para actualizarse.');
    }

    final db = await _databaseHelper.database;

    return db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _databaseHelper.database;

    return db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }
}
