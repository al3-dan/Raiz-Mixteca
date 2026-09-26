PRAGMA foreign_keys = ON;

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
);

CREATE TABLE productos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    productor_id INTEGER NOT NULL,
    nombre TEXT NOT NULL,
    tipo TEXT NOT NULL,
    descripcion TEXT,

    FOREIGN KEY (productor_id)
        REFERENCES productores(id)
        ON DELETE CASCADE
);

CREATE TABLE lotes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    producto_id INTEGER NOT NULL,
    codigo_lote TEXT NOT NULL UNIQUE,
    fecha_produccion TEXT NOT NULL,
    descripcion TEXT,

    FOREIGN KEY (producto_id)
        REFERENCES productos(id)
        ON DELETE CASCADE
);

CREATE TABLE procesos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    lote_id INTEGER NOT NULL UNIQUE,
    descripcion TEXT,
    etapas TEXT,
    observaciones TEXT,

    FOREIGN KEY (lote_id)
        REFERENCES lotes(id)
        ON DELETE CASCADE
);

CREATE TABLE fotografias (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    lote_id INTEGER NOT NULL,
    ruta TEXT NOT NULL,
    descripcion TEXT,

    FOREIGN KEY (lote_id)
        REFERENCES lotes(id)
        ON DELETE CASCADE
);

CREATE INDEX idx_productos_productor
ON productos(productor_id);

CREATE INDEX idx_lotes_producto
ON lotes(producto_id);

CREATE INDEX idx_fotografias_lote
ON fotografias(lote_id);