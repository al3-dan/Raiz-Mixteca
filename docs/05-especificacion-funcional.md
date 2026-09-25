# Especificación funcional de RaizMixteca

## 1. Propósito del documento

Este documento complementa los requisitos, historias de usuario y alcance definidos para RaizMixteca.

Su objetivo es proporcionar una guía más concreta para los integrantes encargados de base de datos, interfaz Flutter, códigos QR y pruebas, reduciendo ambigüedades durante el desarrollo del MVP.

---

## 2. Datos requeridos por el sistema

A nivel funcional, RaizMixteca deberá manejar la siguiente información.

### 2.1 Productor

El sistema deberá permitir registrar al menos:

- Nombre.
- Apellidos.
- Comunidad.
- Municipio.
- Teléfono.
- Correo electrónico.
- Descripción del productor.
- Fecha de registro.
- Indicación de qué datos podrán mostrarse públicamente.

El diseño final de tablas, tipos de datos, claves primarias y claves foráneas será responsabilidad del área de base de datos.

### 2.2 Producto

El sistema deberá permitir registrar:

- Nombre del producto.
- Tipo de producto.
- Descripción.
- Productor asociado.

Los tipos de producto contemplados inicialmente son:

- Miel.
- Pulque.

La estructura deberá permitir agregar nuevos tipos de producto en versiones posteriores.

### 2.3 Lote

Cada lote deberá manejar al menos:

- Identificador único.
- Producto asociado.
- Fecha de producción.
- Descripción.
- Información relacionada con el proceso.
- Fotografías asociadas.

Ejemplo de identificador:

`LOT-000001`

### 2.4 Fotografías

Cada fotografía deberá estar relacionada con un lote o registro correspondiente.

Se deberá conservar al menos:

- Referencia al lote.
- Ruta o referencia de almacenamiento de la imagen.
- Descripción opcional.

### 2.5 Proceso de producción

El sistema deberá permitir registrar información relacionada con el proceso de producción.

Esta información podrá incluir:

- Descripción del proceso.
- Etapas principales.
- Observaciones.
- Información relevante que el productor desee mostrar al consumidor.

En el MVP no es obligatorio manejar cada etapa como una tabla independiente. La estructura final será determinada por el responsable de base de datos.

---

## 3. Actores del sistema

### 3.1 Productor

El productor será el usuario encargado de registrar y administrar la información relacionada con su producción.

Deberá poder:

- Registrar sus datos.
- Modificar sus datos.
- Registrar productos.
- Registrar lotes.
- Agregar fotografías.
- Registrar información del proceso de producción.
- Generar códigos QR.

### 3.2 Consumidor

El consumidor utilizará principalmente el módulo de consulta.

Deberá poder:

- Escanear un código QR.
- Consultar información pública del producto.
- Consultar información del lote.
- Conocer información pública del productor.
- Visualizar fotografías.
- Consultar información del proceso de producción.
- Consultar un medio de contacto autorizado.

---

## 4. Pantallas mínimas del MVP

Para evitar diferencias entre los requisitos y la interfaz, se proponen las siguientes pantallas mínimas.

### 4.1 Inicio

Debe permitir acceder a las principales funciones del sistema.

Opciones principales:

- Productores.
- Productos.
- Lotes.
- Escanear QR.

### 4.2 Lista de productores

Debe mostrar los productores registrados.

Debe permitir:

- Consultar productor.
- Registrar nuevo productor.

### 4.3 Registrar productor

Formulario para capturar los datos definidos para el productor.

### 4.4 Detalle del productor

Debe mostrar:

- Datos del productor.
- Productos asociados.
- Información básica relacionada.

### 4.5 Lista de productos

Debe mostrar los productos registrados.

Debe permitir:

- Consultar producto.
- Registrar producto.

### 4.6 Registrar producto

Debe permitir:

- Seleccionar productor.
- Indicar tipo de producto.
- Registrar nombre.
- Registrar descripción.

### 4.7 Lista de lotes

Debe mostrar los lotes registrados.

Debe permitir:

- Consultar lote.
- Registrar nuevo lote.

### 4.8 Registrar lote

Debe permitir:

- Seleccionar producto.
- Generar o asignar identificador.
- Registrar fecha de producción.
- Registrar descripción.
- Registrar información del proceso.

### 4.9 Detalle del lote

Debe mostrar:

- Código del lote.
- Producto.
- Productor.
- Fecha de producción.
- Proceso.
- Fotografías.
- Opción para generar QR.

### 4.10 Agregar fotografías

Debe permitir asociar fotografías al lote correspondiente.

### 4.11 Generar código QR

Debe mostrar o generar el código QR relacionado con el lote.

### 4.12 Escanear código QR

Debe permitir utilizar la cámara del dispositivo para leer un código QR válido.

### 4.13 Consulta pública

Después de escanear el QR se deberá mostrar la información pública correspondiente al producto, lote y productor.

---

## 5. Flujo principal de navegación

El flujo principal para el productor será:

Inicio  
↓  
Productores  
↓  
Registrar productor  
↓  
Productos  
↓  
Registrar producto  
↓  
Lotes  
↓  
Registrar lote  
↓  
Agregar proceso y fotografías  
↓  
Generar código QR  

El flujo principal para el consumidor será:

Inicio  
↓  
Escanear QR  
↓  
Obtener identificador del lote  
↓  
Buscar lote  
↓  
Obtener producto asociado  
↓  
Obtener productor asociado  
↓  
Mostrar información pública  

---

## 6. Funcionamiento del código QR

El código QR no deberá almacenar toda la información del producto directamente.

Para el MVP se propone que contenga principalmente un identificador único del lote.

Ejemplo:

`LOT-000001`

Flujo:

Código QR  
↓  
Identificador del lote  
↓  
Búsqueda del lote  
↓  
Consulta del producto asociado  
↓  
Consulta del productor asociado  
↓  
Presentación de información pública  

Esta estrategia permite modificar información posteriormente sin necesidad de generar un nuevo QR mientras se conserve el mismo identificador.

---

## 7. Información pública y privada

El sistema deberá diferenciar entre información pública e información interna.

### 7.1 Información pública

Inicialmente se contempla mostrar:

- Nombre del productor.
- Comunidad.
- Nombre del producto.
- Tipo de producto.
- Código del lote.
- Fecha de producción.
- Descripción del producto.
- Información del proceso de producción.
- Fotografías autorizadas.
- Medio de contacto autorizado.

### 7.2 Información interna

No deberá mostrarse automáticamente al consumidor:

- Identificadores internos de base de datos.
- Información que el productor no haya autorizado.
- Datos técnicos utilizados únicamente por la aplicación.
- Información privada del productor.

---

## 8. Funcionamiento sin conexión

Para el MVP, RaizMixteca deberá permitir realizar las funciones principales utilizando almacenamiento local.

Se considera funcionamiento offline:

- Registrar productores sin conexión.
- Registrar productos sin conexión.
- Registrar lotes sin conexión.
- Consultar información almacenada previamente.
- Acceder a fotografías almacenadas localmente.
- Generar códigos QR de lotes locales.

No forma parte del MVP:

- Sincronización automática entre distintos dispositivos.
- Consulta de información almacenada únicamente en otro dispositivo.
- Servicios en tiempo real.
- Base de datos central obligatoria.

---

## 9. Almacenamiento y arquitectura inicial

Para la primera versión se contempla la siguiente arquitectura:

Flutter  
↓  
Servicios de datos  
↓  
SQLite  

SQLite permitirá conservar la información localmente en el dispositivo.

En una etapa posterior podrá evolucionar a:

Flutter  
↓  
API REST  
↓  
PostgreSQL  

La API REST y PostgreSQL no se consideran implementados dentro del MVP actual.

---

## 10. Reglas básicas del sistema

### RG-01

Todo producto deberá estar asociado a un productor.

### RG-02

Todo lote deberá estar asociado a un producto.

### RG-03

Cada lote deberá contar con un identificador único.

### RG-04

Un lote podrá tener cero, una o varias fotografías.

### RG-05

El código QR deberá estar relacionado con un lote válido.

### RG-06

La consulta mediante QR únicamente deberá mostrar información definida como pública.

### RG-07

El sistema deberá impedir que dos lotes utilicen el mismo identificador.

### RG-08

Si un código QR no corresponde a un lote existente, la aplicación deberá informar que el código no fue encontrado.

### RG-09

Los campos obligatorios deberán validarse antes de guardar un registro.

### RG-10

Los datos guardados localmente deberán conservarse después de cerrar y volver a abrir la aplicación.

---

## 11. Validaciones mínimas

### Productor

Campos mínimos recomendados:

- Nombre obligatorio.
- Comunidad obligatoria.
- Municipio obligatorio.

Teléfono y correo podrán definirse como opcionales en el MVP si el equipo así lo decide.

### Producto

- Nombre obligatorio.
- Tipo obligatorio.
- Productor obligatorio.

### Lote

- Producto obligatorio.
- Código único obligatorio.
- Fecha de producción obligatoria.

### QR

- Solo debe generarse para un lote previamente registrado.

---

## 12. Manejo de errores esperado

La aplicación deberá proporcionar mensajes claros en situaciones como:

- Campo obligatorio vacío.
- Producto sin productor asociado.
- Lote sin producto asociado.
- Identificador de lote repetido.
- Código QR no reconocido.
- Lote no encontrado.
- Error al guardar información.
- Fotografía no disponible.

Los mensajes deberán ser comprensibles para el usuario y evitar mostrar errores técnicos internos.

---

## 13. Relación con las historias de usuario

La especificación funcional se relaciona directamente con las historias previamente definidas.

- HU-01: Registrar productor.
- HU-02: Registrar producto.
- HU-03: Registrar lote.
- HU-04: Agregar fotografías.
- HU-05: Registrar proceso de producción.
- HU-06: Generar código QR.
- HU-07: Escanear código QR.
- HU-08: Consultar origen del producto.
- HU-09: Consultar proceso de producción.
- HU-10: Consultar datos de contacto.

---

## 14. Responsabilidades para los integrantes

### Integrante 2 — Base de datos

A partir de este documento deberá:

- Definir entidades definitivas.
- Definir atributos.
- Definir tipos de datos.
- Establecer claves primarias y foráneas.
- Definir relaciones.
- Crear el modelo entidad-relación.
- Implementar SQLite.
- Validar persistencia de datos.

### Integrante 3 — Flutter e interfaz

A partir de este documento deberá:

- Crear las pantallas mínimas.
- Diseñar formularios.
- Implementar navegación.
- Implementar validaciones visuales.
- Integrar la interfaz con los datos proporcionados por el módulo de almacenamiento.

### Integrante 4 — QR, trazabilidad y pruebas

A partir de este documento deberá:

- Implementar generación de QR.
- Implementar lectura de QR.
- Utilizar el identificador único del lote.
- Definir la consulta pública.
- Crear casos de prueba.
- Validar escenarios correctos y de error.

---

## 15. Consideraciones finales

Esta especificación corresponde al MVP de RaizMixteca.

Cualquier funcionalidad nueva que modifique significativamente el alcance deberá ser revisada por el equipo antes de implementarse.

El objetivo principal es lograr un flujo funcional y demostrable:

Registrar productor  
↓  
Registrar producto  
↓  
Registrar lote  
↓  
Agregar información  
↓  
Generar QR  
↓  
Escanear QR  
↓  
Mostrar información del producto y productor
