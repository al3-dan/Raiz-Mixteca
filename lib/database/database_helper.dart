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
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'raiz_mixteca.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _crearBaseDeDatos,
      onUpgrade: _actualizarBaseDeDatos,
    );
  }

  // ==========================================================
  // CREACIÓN INICIAL DE TODA LA BASE DE DATOS
  // ==========================================================

  Future<void> _crearBaseDeDatos(Database db, int version) async {
    await _crearTablasBase(db);
  }

  Future<void> _crearTablasBase(Database db) async {
    // ========================================================
    // PRODUCTORES
    // ========================================================

    await db.execute('''
      CREATE TABLE IF NOT EXISTS productores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        apellidos TEXT NOT NULL,
        comunidad TEXT NOT NULL,
        municipio TEXT NOT NULL,
        telefono TEXT,
        correo TEXT,
        descripcion TEXT,
        usuario TEXT NOT NULL UNIQUE,
        contrasena TEXT NOT NULL,
        mostrar_nombre INTEGER NOT NULL DEFAULT 1,
        mostrar_comunidad INTEGER NOT NULL DEFAULT 1,
        mostrar_contacto INTEGER NOT NULL DEFAULT 0,
        fecha_registro TEXT NOT NULL
      )
    ''');

    // ========================================================
    // PRODUCTOS
    // ========================================================

    await db.execute('''
      CREATE TABLE IF NOT EXISTS productos (
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

    // ========================================================
    // LOTES
    // ========================================================

    await db.execute('''
      CREATE TABLE IF NOT EXISTS lotes (
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

    // ========================================================
    // PROCESOS
    // ========================================================

    await db.execute('''
      CREATE TABLE IF NOT EXISTS procesos (
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

    // ========================================================
    // FOTOGRAFÍAS
    // ========================================================

    await db.execute('''
      CREATE TABLE IF NOT EXISTS fotografias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lote_id INTEGER NOT NULL,
        ruta TEXT NOT NULL,
        descripcion TEXT,
        FOREIGN KEY (lote_id)
          REFERENCES lotes(id)
          ON DELETE CASCADE
      )
    ''');

    // ========================================================
    // MENSAJES
    // ========================================================

    await _crearTablasComunicacion(db);

    // ========================================================
    // ÍNDICES
    // ========================================================

    await _crearIndices(db);
  }

  // ==========================================================
  // TABLAS DE COMUNICACIÓN
  // ==========================================================

  Future<void> _crearTablasComunicacion(Database db) async {
    // --------------------------------------------------------
    // MENSAJES ENTRE PRODUCTORES
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS mensajes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remitente_id INTEGER NOT NULL,
        destinatario_id INTEGER NOT NULL,
        asunto TEXT,
        contenido TEXT NOT NULL,
        fecha TEXT NOT NULL,
        leido INTEGER NOT NULL DEFAULT 0,

        FOREIGN KEY (remitente_id)
          REFERENCES productores(id)
          ON DELETE CASCADE,

        FOREIGN KEY (destinatario_id)
          REFERENCES productores(id)
          ON DELETE CASCADE
      )
    ''');

    // --------------------------------------------------------
    // PEDIDOS / SOLICITUDES
    // --------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productor_id INTEGER NOT NULL,
        producto_id INTEGER,
        nombre_cliente TEXT NOT NULL,
        contacto_cliente TEXT,
        cantidad REAL NOT NULL DEFAULT 1,
        descripcion TEXT,
        estado TEXT NOT NULL DEFAULT 'pendiente',
        monto REAL NOT NULL DEFAULT 0,
        fecha TEXT NOT NULL,

        FOREIGN KEY (productor_id)
          REFERENCES productores(id)
          ON DELETE CASCADE,

        FOREIGN KEY (producto_id)
          REFERENCES productos(id)
          ON DELETE SET NULL
      )
    ''');
  }

  // ==========================================================
  // ÍNDICES
  // ==========================================================

  Future<void> _crearIndices(Database db) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_productos_productor
      ON productos(productor_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_lotes_producto
      ON lotes(producto_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_fotografias_lote
      ON fotografias(lote_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_mensajes_destinatario
      ON mensajes(destinatario_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_mensajes_remitente
      ON mensajes(remitente_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_mensajes_fecha
      ON mensajes(fecha)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_pedidos_productor
      ON pedidos(productor_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_pedidos_producto
      ON pedidos(producto_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_pedidos_estado
      ON pedidos(estado)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_pedidos_fecha
      ON pedidos(fecha)
    ''');
  }

  // ==========================================================
  // MIGRACIONES
  // ==========================================================

  Future<void> _actualizarBaseDeDatos(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // ========================================================
    // VERSIÓN 1 -> 2
    // Agregar datos de acceso a productores
    // ========================================================

    if (oldVersion < 2) {
      await _agregarColumnasVersion2(db);
    }

    // ========================================================
    // VERSIÓN 2 -> 3
    // Agregar mensajes y pedidos
    // ========================================================

    if (oldVersion < 3) {
      await _crearTablasComunicacion(db);
      await _crearIndices(db);
    }

    // ========================================================
    // SEGURIDAD:
    // Nos aseguramos de que las tablas nuevas existan aunque
    // la base venga de una instalación anterior.
    // ========================================================

    await _asegurarTablasNuevas(db);
  }

  // ==========================================================
  // MIGRACIÓN A VERSIÓN 2
  // ==========================================================

  Future<void> _agregarColumnasVersion2(Database db) async {
    try {
      await db.execute('''
        ALTER TABLE productores
        ADD COLUMN usuario TEXT
      ''');
    } catch (_) {}

    try {
      await db.execute('''
        ALTER TABLE productores
        ADD COLUMN contrasena TEXT
      ''');
    } catch (_) {}

    try {
      await db.execute('''
        ALTER TABLE productores
        ADD COLUMN mostrar_nombre INTEGER
        NOT NULL DEFAULT 1
      ''');
    } catch (_) {}

    try {
      await db.execute('''
        ALTER TABLE productores
        ADD COLUMN mostrar_comunidad INTEGER
        NOT NULL DEFAULT 1
      ''');
    } catch (_) {}

    try {
      await db.execute('''
        ALTER TABLE productores
        ADD COLUMN mostrar_contacto INTEGER
        NOT NULL DEFAULT 0
      ''');
    } catch (_) {}

    try {
      await db.execute('''
        ALTER TABLE productores
        ADD COLUMN fecha_registro TEXT
      ''');
    } catch (_) {}

    // --------------------------------------------------------
    // Completar datos de cuentas antiguas
    // --------------------------------------------------------

    try {
      final productores = await db.query('productores', columns: ['id']);

      for (final productor in productores) {
        final id = productor['id'];

        await db.update(
          'productores',
          {
            'usuario': 'productor_$id',
            'contrasena': '1234',
            'mostrar_nombre': 1,
            'mostrar_comunidad': 1,
            'mostrar_contacto': 0,
            'fecha_registro': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (_) {}
  }

  // ==========================================================
  // ASEGURAR TABLAS NUEVAS
  // ==========================================================

  Future<void> _asegurarTablasNuevas(Database db) async {
    // Si la tabla no existe, la crea.
    await _crearTablasComunicacion(db);

    // Los índices tampoco causan problema si ya existen.
    await _crearIndices(db);
  }

  // ==========================================================
  // UTILIDADES
  // ==========================================================

  Future<void> cerrarBaseDeDatos() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
