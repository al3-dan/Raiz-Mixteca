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

## 5. Registro de ejecución — 27/09/2026

**Entorno disponible:** Windows 11; Flutter detectó Windows, Chrome, Edge y un teléfono Android 16 (RMX3867). En el primer intento no había dispositivo móvil conectado. En el reintento, el teléfono fue detectado, pero la app no llegó a compilarse/instalarse: el NDK `28.2.13676358` local solo contiene `.installer` y no tiene `source.properties`; Gradle falló al invocar `sdkmanager` (exit code `-1073740791`). Las pruebas funcionales y capturas siguen pendientes.

| ID | Estado | Resultado de esta sesión | Evidencia pendiente |
|---|---|---|---|
| P-01 | Pendiente manual | No se ejecutó el flujo de alta en la app; la compilación Android no completó. | `P-01-productor.png` |
| P-02 | Pendiente manual | No se ejecutó el flujo de alta y asociación en la app; la compilación Android no completó. | `P-02-producto.png` |
| P-03 | Parcial, automatizado | El test valida el formato y extracción del identificador; no prueba `MAX(id)+1` en SQLite ni el registro desde la app. | `P-03-lote.png` |
| P-04 | Pendiente de validación visual | La pantalla genera y comparte una imagen QR; falta decodificarla con un lector y confirmar el contenido en dispositivo. | `P-04-qr-generado.png` |
| P-05 | Pendiente de dispositivo | El teléfono se detectó, pero la app no se instaló; no se pudo abrir el escáner ni dar acceso a la cámara. | `P-05-consulta-publica.png` |
| P-06 | Pendiente manual | La app usa SQLite local, pero el recorrido de escaneo sin conexión no se ejecutó. | `P-06-sin-internet.png` |
| P-07 | Pendiente de dispositivo | No se instaló la app; no se capturó una fotografía ni se comprobó su visualización pública. | `P-07-fotografia-publica.png` |

**Verificación automatizada ejecutada:** `flutter test` pasó (3 tests). `flutter analyze` terminó con `No issues found!`.

Las evidencias visuales deben guardarse en `docs/evidencias/pruebas/` con los nombres indicados. No se agregan capturas de ejemplo como si fueran resultados reales. Para reintentar en el teléfono, reparar/instalar el NDK `28.2.13676358` con una versión compatible de Java/sdmanager y volver a ejecutar `flutter run -d 99QGKJFI8P5TSO7D`.
