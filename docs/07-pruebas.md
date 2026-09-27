# 05 — Pruebas

**Integrante responsable:** Integrante 4
**Módulo:** QR + trazabilidad + pruebas

## 1. Objetivo

Definir el conjunto inicial de pruebas funcionales que validan el flujo completo de RaízMixteca: desde el registro de un productor hasta la consulta pública de un lote vía QR, incluyendo escenarios sin conexión.

## 2. Tabla de pruebas

| ID | Prueba | Resultado esperado |
|---|---|---|
| P-01 | Registrar productor | El productor queda guardado en el sistema con sus datos básicos (nombre, comunidad, contacto). |
| P-02 | Registrar producto | El producto queda guardado y asociado correctamente a su productor. |
| P-03 | Registrar lote | Se crea un lote con identificador único, vinculado al producto y al productor correspondientes. |
| P-04 | Generar QR | Se genera un código QR válido que codifica el identificador único del lote (`LOT-XXXXXX`). |
| P-05 | Escanear QR | Al escanear el QR, se muestra correctamente la información pública del producto, productor y lote. |
| P-06 | Sin Internet | Si el dispositivo no tiene conexión, los datos previamente cacheados/almacenados localmente siguen disponibles para su consulta. |
| P-07 | Fotografía | Una fotografía subida queda asociada correctamente al lote/producto y se muestra en la pantalla pública. |

## 3. Detalle de cada prueba

### P-01 — Registrar productor
- **Precondición:** No existe el productor en el sistema.
- **Pasos:** Capturar nombre, comunidad y datos de contacto; guardar.
- **Resultado esperado:** El productor aparece en el listado/registro con un identificador propio.
- **Criterio de éxito:** Los datos guardados coinciden exactamente con los capturados.

### P-02 — Registrar producto
- **Precondición:** Existe al menos un productor registrado (P-01).
- **Pasos:** Capturar nombre y descripción del producto; asociarlo a un productor existente; guardar.
- **Resultado esperado:** El producto queda visible y correctamente ligado a su productor.
- **Criterio de éxito:** Consultar el producto devuelve el productor correcto.

### P-03 — Registrar lote
- **Precondición:** Existe al menos un producto registrado (P-02).
- **Pasos:** Capturar fecha de producción y proceso; asociar el lote a un producto existente; guardar.
- **Resultado esperado:** Se crea un lote con un identificador único autogenerado (ej. `LOT-000001`).
- **Criterio de éxito:** El identificador generado no se repite con ningún lote anterior.

### P-04 — Generar QR
- **Precondición:** Existe un lote registrado (P-03).
- **Pasos:** Solicitar la generación del QR para ese lote.
- **Resultado esperado:** Se genera una imagen de QR que codifica la URL/identificador del lote.
- **Criterio de éxito:** Al decodificar el QR manualmente (con cualquier lector), el contenido corresponde al identificador correcto del lote.

### P-05 — Escanear QR
- **Precondición:** Existe un QR generado (P-04) y el lote tiene producto y productor asociados.
- **Pasos:** Escanear el QR desde un dispositivo con la app o cámara.
- **Resultado esperado:** Se muestra la pantalla pública con: producto, productor, comunidad, lote, fecha de producción, proceso y fotografías (si existen).
- **Criterio de éxito:** Toda la información mostrada coincide con los datos registrados para ese lote.

### P-06 — Sin Internet
- **Precondición:** El dispositivo consultó previamente al menos un lote mientras tenía conexión (para que exista caché local).
- **Pasos:** Desactivar la conexión a internet; volver a escanear el mismo QR o abrir la app.
- **Resultado esperado:** La información del lote consultado previamente sigue disponible, aunque no haya conexión.
- **Criterio de éxito:** No se muestra error bloqueante; se muestra al menos la información previamente cacheada (puede indicarse que los datos podrían no estar actualizados).

### P-07 — Fotografía
- **Precondición:** Existe un lote o producto registrado.
- **Pasos:** Subir una fotografía y asociarla al lote/producto correspondiente.
- **Resultado esperado:** La fotografía se guarda y queda vinculada al registro correcto.
- **Criterio de éxito:** La fotografía aparece en la pantalla pública de ese lote al escanear su QR.

## 4. Notas generales

- Estas pruebas son el punto de partida; conforme avance el desarrollo de los demás módulos (registro de productores/productos/lotes, generación de QR, backend) se pueden agregar pruebas de casos límite (ej. lote duplicado, producto sin fotos, productor sin datos de contacto).
- P-06 depende de que exista una estrategia de almacenamiento local (caché) definida por el equipo; este documento solo establece el criterio de aceptación, no la implementación.
