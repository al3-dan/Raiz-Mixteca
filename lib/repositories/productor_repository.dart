import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/productor.dart';

class ProductorRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // ============================================================
  // INSERTAR PRODUCTOR
  // ============================================================

  Future<int> insertar(Productor productor) async {
    final db = await _databaseHelper.database;

    // Verificar que el usuario no exista.
    final usuarioExistente = await db.query(
      'productores',
      where: 'usuario = ?',
      whereArgs: [productor.usuario],
      limit: 1,
    );

    if (usuarioExistente.isNotEmpty) {
      throw Exception('El nombre de usuario ya está registrado.');
    }

    return db.insert(
      'productores',
      productor.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // ============================================================
  // OBTENER TODOS
  // ============================================================

  Future<List<Productor>> obtenerTodos() async {
    final db = await _databaseHelper.database;

    final maps = await db.query('productores', orderBy: 'id DESC');

    return maps.map(Productor.fromMap).toList();
  }

  // ============================================================
  // OBTENER POR ID
  // ============================================================

  Future<Productor?> obtenerPorId(int id) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'productores',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Productor.fromMap(maps.first);
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<Productor?> iniciarSesion(String usuario, String contrasena) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'productores',
      where: 'usuario = ? AND contrasena = ?',
      whereArgs: [usuario.trim(), contrasena],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Productor.fromMap(maps.first);
  }

  // ============================================================
  // COMPROBAR USUARIO
  // ============================================================

  Future<bool> existeUsuario(String usuario, {int? excluirId}) async {
    final db = await _databaseHelper.database;

    String where = 'usuario = ?';
    List<Object?> whereArgs = [usuario.trim()];

    if (excluirId != null) {
      where += ' AND id != ?';
      whereArgs.add(excluirId);
    }

    final maps = await db.query(
      'productores',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  // ============================================================
  // ACTUALIZAR
  // ============================================================

  Future<int> actualizar(Productor productor) async {
    if (productor.id == null) {
      throw ArgumentError('El productor debe tener un id para actualizarse.');
    }

    final db = await _databaseHelper.database;

    final usuarioExistente = await existeUsuario(
      productor.usuario,
      excluirId: productor.id,
    );

    if (usuarioExistente) {
      throw Exception('El nombre de usuario ya está registrado.');
    }

    return db.update(
      'productores',
      productor.toMap(),
      where: 'id = ?',
      whereArgs: [productor.id],
    );
  }

  // ============================================================
  // ELIMINAR
  // ============================================================

  Future<int> eliminar(int id) async {
    final db = await _databaseHelper.database;

    return db.delete('productores', where: 'id = ?', whereArgs: [id]);
  }
}
