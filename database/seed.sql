PRAGMA foreign_keys = ON;

INSERT INTO productores (
    nombre,
    apellidos,
    comunidad,
    municipio,
    telefono,
    correo,
    descripcion,
    mostrar_nombre,
    mostrar_comunidad,
    mostrar_contacto,
    fecha_registro
)
VALUES (
    'Juan',
    'Pérez López',
    'San Miguel',
    'Municipio de prueba',
    '5551234567',
    'juan@example.com',
    'Productor local de miel.',
    1,
    1,
    1,
    '2026-09-26'
);

INSERT INTO productos (
    productor_id,
    nombre,
    tipo,
    descripcion
)
VALUES (
    1,
    'Miel artesanal',
    'Miel',
    'Miel producida localmente.'
);

INSERT INTO lotes (
    producto_id,
    codigo_lote,
    fecha_produccion,
    descripcion
)
VALUES (
    1,
    'LOT-000001',
    '2026-09-25',
    'Lote de prueba.'
);

INSERT INTO procesos (
    lote_id,
    descripcion,
    etapas,
    observaciones
)
VALUES (
    1,
    'Proceso artesanal de producción.',
    'Recolección, extracción y envasado.',
    'Registro utilizado para pruebas.'
);

INSERT INTO fotografias (
    lote_id,
    ruta,
    descripcion
)
VALUES (
    1,
    'images/lote_000001.jpg',
    'Fotografía de prueba.'
);