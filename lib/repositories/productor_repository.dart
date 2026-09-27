import '../database/database_helper.dart';
import '../models/productor.dart';

class ProductorRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insertar(Productor productor) async {
    final db = await _databaseHelper.database;

    return db.insert('productores', productor.toMap());
  }

  Future<List<Productor>> obtenerTodos() async {
    final db = await _databaseHelper.database;

    final maps = await db.query('productores', orderBy: 'id DESC');

    return maps.map(Productor.fromMap).toList();
  }

  Future<Productor?> obtenerPorId(int id) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      'productores',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Productor.fromMap(maps.first);
  }

  Future<int> actualizar(Productor productor) async {
    final db = await _databaseHelper.database;

    return db.update(
      'productores',
      productor.toMap(),
      where: 'id = ?',
      whereArgs: [productor.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _databaseHelper.database;

    return db.delete('productores', where: 'id = ?', whereArgs: [id]);
  }
}
