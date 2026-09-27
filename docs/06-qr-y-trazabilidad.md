# 04 — QR y Trazabilidad

**Integrante responsable:** Integrante 4
**Módulo:** QR + trazabilidad + pruebas

## 1. Objetivo

Definir cómo se identifica un producto de RaízMixteca mediante un código QR, y cómo ese código permite reconstruir toda la información de trazabilidad (productor, comunidad, lote, proceso) sin necesidad de almacenar esos datos directamente en el propio QR.

## 2. Tarea 1 — ¿Qué contiene el QR?

### 2.1 Decisión de diseño

El QR **no** contiene los datos del producto (nombre, productor, fotos, descripción, etc.). Contiene únicamente un **identificador único de lote**, que la app/backend de RaízMixteca usa para buscar la información asociada.

```
QR
 │
 ▼
Identificador único
 │
 ▼
LOT-000001
```

### 2.2 ¿Por qué no poner todos los datos en el QR?

| Opción | Ventajas | Desventajas |
|---|---|---|
| Todos los datos dentro del QR | Funciona sin conexión a internet, sin backend | El QR queda "congelado": si el dato cambia (ej. error de captura, nueva foto, corrección de nombre) hay que **reimprimir y volver a pegar el QR físico** en todos los empaques. QR más denso y pesado. |
| Solo un identificador dentro del QR (elegido) | El contenido se puede actualizar en cualquier momento sin tocar el QR físico ya impreso. QR simple, pequeño, rápido de escanear. Permite agregar información nueva con el tiempo (ej. certificaciones, nuevas fotos). | Requiere que el dispositivo tenga conexión (o datos locales cacheados) para resolver el identificador → información. |

Esta es la razón principal de la decisión: **separar identidad de contenido**. El QR identifica el lote; el sistema resuelve qué significa ese identificador en el momento de la consulta.

### 2.3 Formato del identificador

- Prefijo `LOT-` + número consecutivo de 6 dígitos con ceros a la izquierda.
- Ejemplo: `LOT-000001`, `LOT-000002`, …
- Es único por lote, no por producto ni por productor (un mismo producto puede tener varios lotes a lo largo del tiempo, y cada lote conserva su propia trazabilidad: fecha, proceso, fotos de esa producción específica).

### 2.4 ¿Qué va codificado literalmente en el QR?

El QR codifica una URL (no solo el texto plano del ID), para que al escanearlo con cualquier lector de cámara —no solo la app de RaízMixteca— se abra directamente la página pública del lote:

```
https://raizmixteca.example/lote/LOT-000001
```

La app/backend recibe el `LOT-000001` como parámetro de ruta y a partir de ahí resuelve toda la búsqueda descrita en la Tarea 2.

## 3. Tarea 2 — Flujo del consumidor

### 3.1 Diagrama de flujo

```
Consumidor
    ↓
Escanea QR
    ↓
RaízMixteca obtiene ID (LOT-000001)
    ↓
Busca lote
    ↓
Obtiene producto
    ↓
Obtiene productor
    ↓
Muestra información pública
```

### 3.2 Descripción paso a paso

1. **Escanea QR** — el consumidor usa la cámara del teléfono (o la app) para escanear el código impreso en el empaque.
2. **RaízMixteca obtiene el ID** — se extrae el identificador `LOT-000001` de la URL codificada.
3. **Busca lote** — el sistema consulta el registro de lotes con ese identificador.
4. **Obtiene producto** — desde el lote se obtiene la referencia al producto asociado (ej. "Miel multifloral").
5. **Obtiene productor** — desde el producto (o desde el lote, según el modelo de datos) se obtiene la referencia al productor y su comunidad.
6. **Muestra información pública** — se renderiza una pantalla con los datos pensados para el consumidor final (no datos internos/administrativos).

### 3.3 Mockup de la pantalla pública

```
PRODUCTO

🍯 Miel multifloral

Productor:
Nombre del productor

Comunidad:
San Juan Ñumí

Lote:
LOT-000001

Producción:
Septiembre 2026

Proceso:
...

[ Fotografías ]

[ Contactar productor ]
```

### 3.4 Notas sobre la información mostrada

- Solo se muestra **información pública**: no se exponen datos sensibles del productor (teléfono directo, dirección exacta, etc.) salvo que el productor haya optado explícitamente por mostrarlos (ej. botón "Contactar productor" que abre un canal controlado, no el dato crudo).
- El botón **"Contactar productor"** es la única vía de contacto sugerida; su implementación (WhatsApp, formulario, correo) queda fuera del alcance de este documento y depende de lo que definan los integrantes responsables de esa parte del sistema.

## 4. Relación con el resto del sistema

Este flujo depende de que existan, previamente:

- Un registro de **productores** (nombre, comunidad, datos de contacto internos).
- Un registro de **productos** (nombre, descripción, tipo).
- Un registro de **lotes** (identificador único, fecha de producción, proceso, fotografías, producto asociado, productor asociado).

La generación y el escaneo del QR son la "puerta de entrada" pública a esos registros, pero no reemplazan el trabajo de captura de datos que hacen los demás módulos del proyecto.

## 5. Resumen de la decisión clave

> El QR es solo un puntero (`LOT-000001`), no un contenedor de datos. Esto separa la identidad física del producto (el QR impreso, que no cambia) de su contenido informativo (que sí puede evolucionar con el tiempo).
