# Diccionario de Datos de RaízMixteca

## 1. Tabla: productores

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | INTEGER | PK | Identificador interno del productor |
| nombre | TEXT | NOT NULL | Nombre del productor |
| apellidos | TEXT | NOT NULL | Apellidos del productor |
| comunidad | TEXT | NOT NULL | Comunidad donde se encuentra el productor |
| municipio | TEXT | NOT NULL | Municipio del productor |
| telefono | TEXT | NULL | Teléfono del productor |
| correo | TEXT | NULL | Correo electrónico |
| descripcion | TEXT | NULL | Descripción del productor |
| mostrar_nombre | INTEGER | NOT NULL | Indica si el nombre puede mostrarse públicamente |
| mostrar_comunidad | INTEGER | NOT NULL | Indica si la comunidad puede mostrarse públicamente |
| mostrar_contacto | INTEGER | NOT NULL | Indica si el contacto puede mostrarse públicamente |
| fecha_registro | TEXT | NOT NULL | Fecha de registro |

## 2. Tabla: productos

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | INTEGER | PK | Identificador interno del producto |
| productor_id | INTEGER | FK, NOT NULL | Productor asociado |
| nombre | TEXT | NOT NULL | Nombre del producto |
| tipo | TEXT | NOT NULL | Tipo de producto, inicialmente Miel o Pulque |
| descripcion | TEXT | NULL | Descripción del producto |

## 3. Tabla: lotes

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | INTEGER | PK | Identificador interno del lote |
| producto_id | INTEGER | FK, NOT NULL | Producto asociado |
| codigo_lote | TEXT | UNIQUE, NOT NULL | Identificador público del lote |
| fecha_produccion | TEXT | NOT NULL | Fecha de producción |
| descripcion | TEXT | NULL | Descripción del lote |

## 4. Tabla: procesos

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | INTEGER | PK | Identificador interno |
| lote_id | INTEGER | FK, UNIQUE, NOT NULL | Lote asociado |
| descripcion | TEXT | NULL | Descripción general del proceso |
| etapas | TEXT | NULL | Etapas principales del proceso |
| observaciones | TEXT | NULL | Observaciones adicionales |

## 5. Tabla: fotografias

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | INTEGER | PK | Identificador de la fotografía |
| lote_id | INTEGER | FK, NOT NULL | Lote asociado |
| ruta | TEXT | NOT NULL | Ruta o referencia del archivo |
| descripcion | TEXT | NULL | Descripción de la fotografía |

## 6. Relaciones

- Productor 1:N Producto.
- Producto 1:N Lote.
- Lote 1:1 Proceso.
- Lote 1:N Fotografía.

## 7. Identificador para QR

El campo `codigo_lote` será único.

Ejemplo:

`LOT-000001`

El código QR utilizará este identificador para localizar el lote
correspondiente dentro de la aplicación.