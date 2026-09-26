# Modelo Entidad-Relación de RaízMixteca

## 1. Objetivo

El modelo de datos de RaízMixteca tiene como objetivo organizar la información
relacionada con productores locales, productos, lotes de producción,
información del proceso y fotografías.

## 2. Entidades

El modelo está compuesto por las siguientes entidades:

- Productor
- Producto
- Lote
- Proceso
- Fotografía

## 3. Relaciones

### Productor - Producto

Un productor puede registrar uno o varios productos.

Relación:

**Productor 1:N Producto**

### Producto - Lote

Un producto puede tener uno o varios lotes de producción.

Relación:

**Producto 1:N Lote**

### Lote - Proceso

Cada lote puede tener un registro de información del proceso.

Para el MVP se establece una relación:

**Lote 1:1 Proceso**

### Lote - Fotografía

Un lote puede tener cero, una o varias fotografías.

Relación:

**Lote 1:N Fotografía**

## 4. Identificador de lote

Cada lote tendrá un identificador único con el formato:

`LOT-000001`

Este identificador será utilizado posteriormente como referencia
para la generación y consulta mediante códigos QR.

## 5. Diagrama

El diagrama entidad-relación se encuentra en:

`modelo-er.png`