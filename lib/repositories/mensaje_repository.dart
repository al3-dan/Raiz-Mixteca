import '../database/database_helper.dart';
import '../models/mensaje.dart';

import 'package:sqflite/sqflite.dart';

class MensajeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // ============================================================
  // ENVIAR MENSAJE
  // ============================================================

  Future<int> insertar(Mensaje mensaje) async {
    final db = await _databaseHelper.database;

    return await db.insert('mensajes', mensaje.toMap());
  }

  // ============================================================
  // MENSAJES RECIBIDOS
  // ============================================================

  Future<List<Mensaje>> obtenerRecibidos(int productorId) async {
    final db = await _databaseHelper.database;

    final resultado = await db.query(
      'mensajes',
      where: 'destinatario_id = ?',
      whereArgs: [productorId],
      orderBy: 'fecha DESC',
    );

    return resultado.map((map) => Mensaje.fromMap(map)).toList();
  }

  // ============================================================
  // MENSAJES ENVIADOS
  // ============================================================

  Future<List<Mensaje>> obtenerEnviados(int productorId) async {
    final db = await _databaseHelper.database;

    final resultado = await db.query(
      'mensajes',
      where: 'remitente_id = ?',
      whereArgs: [productorId],
      orderBy: 'fecha DESC',
    );

    return resultado.map((map) => Mensaje.fromMap(map)).toList();
  }

  // ============================================================
  // CONVERSACIÓN
  // ============================================================

  Future<List<Mensaje>> obtenerConversacion(
    int productorA,
    int productorB,
  ) async {
    final db = await _databaseHelper.database;

    final resultado = await db.query(
      'mensajes',
      where: '''
        (remitente_id = ? AND destinatario_id = ?)
        OR
        (remitente_id = ? AND destinatario_id = ?)
      ''',
      whereArgs: [productorA, productorB, productorB, productorA],
      orderBy: 'fecha ASC',
    );

    return resultado.map((map) => Mensaje.fromMap(map)).toList();
  }

  // ============================================================
  // MARCAR COMO LEÍDO
  // ============================================================

  Future<int> marcarComoLeido(int mensajeId) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'mensajes',
      {'leido': 1},
      where: 'id = ?',
      whereArgs: [mensajeId],
    );
  }

  // ============================================================
  // MARCAR TODOS COMO LEÍDOS
  // ============================================================

  Future<int> marcarTodosComoLeidos(int productorId) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'mensajes',
      {'leido': 1},
      where: 'destinatario_id = ? AND leido = 0',
      whereArgs: [productorId],
    );
  }

  // ============================================================
  // CONTAR NO LEÍDOS
  // ============================================================

  Future<int> contarNoLeidos(int productorId) async {
    final db = await _databaseHelper.database;

    final resultado = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM mensajes
      WHERE destinatario_id = ?
        AND leido = 0
      ''',
      [productorId],
    );

    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  // ============================================================
  // ELIMINAR MENSAJE
  // ============================================================

  Future<int> eliminar(int mensajeId) async {
    final db = await _databaseHelper.database;

    return await db.delete('mensajes', where: 'id = ?', whereArgs: [mensajeId]);
  }
}
