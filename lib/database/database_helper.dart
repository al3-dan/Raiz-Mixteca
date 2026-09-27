import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'raiz_mixteca.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE productores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            apellidos TEXT NOT NULL,
            comunidad TEXT NOT NULL,
            municipio TEXT NOT NULL,
            telefono TEXT,
            correo TEXT,
            descripcion TEXT,
            mostrar_nombre INTEGER NOT NULL DEFAULT 1,
            mostrar_comunidad INTEGER NOT NULL DEFAULT 1,
            mostrar_contacto INTEGER NOT NULL DEFAULT 0,
            fecha_registro TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE productos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productor_id INTEGER NOT NULL,
            nombre TEXT NOT NULL,
            tipo TEXT NOT NULL,
            descripcion TEXT,
            FOREIGN KEY (productor_id)
              REFERENCES productores(id)
              ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE lotes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            producto_id INTEGER NOT NULL,
            codigo_lote TEXT NOT NULL UNIQUE,
            fecha_produccion TEXT NOT NULL,
            descripcion TEXT,
            FOREIGN KEY (producto_id)
              REFERENCES productos(id)
              ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE procesos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lote_id INTEGER NOT NULL UNIQUE,
            descripcion TEXT,
            etapas TEXT,
            observaciones TEXT,
            FOREIGN KEY (lote_id)
              REFERENCES lotes(id)
              ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE fotografias (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lote_id INTEGER NOT NULL,
            ruta TEXT NOT NULL,
            descripcion TEXT,
            FOREIGN KEY (lote_id)
              REFERENCES lotes(id)
              ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_productos_productor
          ON productos(productor_id)
        ''');

        await db.execute('''
          CREATE INDEX idx_lotes_producto
          ON lotes(producto_id)
        ''');

        await db.execute('''
          CREATE INDEX idx_fotografias_lote
          ON fotografias(lote_id)
        ''');
      },
    );
  }
}
