import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/lote.dart';

class LoteRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  static String generarCodigoLote(int id) {
    if (id <= 0) {
      throw ArgumentError('El identificador del lote debe ser mayor a 0.');
    }

    return 'LOT-${id.toString().padLeft(6, '0')}';
  }

  static String? extraerCodigoLote(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return null;
    }

    final texto = valor.trim();
    final uri = Uri.tryParse(texto);

    if (uri != null) {
      final segmentos = uri.pathSegments
          .where((segment) => segment.isNotEmpty)
          .toList();
      for (final segmento in segmentos.reversed) {
        final match = RegExp(r'LOT-\d{6}').stringMatch(segmento);
        if (match != null) {
          return match;
        }
      }

      final queryMatch = RegExp(r'LOT-\d{6}').stringMatch(uri.query);
      if (queryMatch != null) {
        return queryMatch;
      }
    }

    final match = RegExp(r'LOT-\d{6}').stringMatch(texto);
    if (match != null) {
      return match;
    }

    return null;
  }

  Future<String> generarSiguienteCodigo() async {
    final db = await _databaseHelper.database;

    final resultado = await db.rawQuery(
      'SELECT COALESCE(MAX(id), 0) AS max_id FROM lotes',
    );

    final maxId = resultado.first['max_id'] as int? ?? 0;

    return generarCodigoLote(maxId + 1);
  }

  Future<Lote?> obtenerPorCodigo(String codigo) async {
    final identificador = extraerCodigoLote(codigo);

    if (identificador == null) {
      return null;
    }

    final db = await _databaseHelper.database;

    final maps = await db.query(
      'lotes',
      where: 'codigo_lote = ?',
      whereArgs: [identificador],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Lote.fromMap(maps.first);
  }

  Future<int> insertar(Lote lote) async {
    final db = await _databaseHelper.database;
    final codigoLote = lote.codigoLote.trim().isEmpty
        ? await generarSiguienteCodigo()
        : lote.codigoLote.trim().toUpperCase();

    final loteConCodigo = Lote(
      id: lote.id,
      productoId: lote.productoId,
      codigoLote: codigoLote,
      fechaProduccion: lote.fechaProduccion,
      descripcion: lote.descripcion,
    );

    return db.insert(
      'lotes',
      loteConCodigo.toMap(),
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
