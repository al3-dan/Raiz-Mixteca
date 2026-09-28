# Avance de QR y trazabilidad — 27/09/2026

## Implementado

- Identificadores secuenciales de lote con formato `LOT-000001`.
- Generación de QR que contiene la URL identificadora del lote y opción para compartirlo como imagen PNG.
- Escáner con validación de formato y mensajes para códigos no reconocidos o lotes inexistentes.
- Consulta pública local del producto, lote, proceso, fotografías y datos del productor según sus preferencias de visibilidad.

## Verificación técnica

- `flutter test`: aprobado, 3 tests.
- `flutter analyze`: sin incidencias.

## Pruebas funcionales

P-03 tiene cobertura automatizada parcial para el formato y extracción del código; el cálculo consecutivo en SQLite requiere validación manual. P-04 está implementada, pero falta decodificar la imagen QR en un lector. P-01, P-02, P-05, P-06 y P-07 también requieren ejecución manual. El 27/09/2026 se detectó el teléfono Android 16 RMX3867, pero la app no llegó a compilarse/instalarse porque el NDK `28.2.13676358` está incompleto y `sdkmanager` terminó con error `-1073740791`.

No se reportan capturas como evidencia porque todavía no se han tomado en la app real. Al ejecutar cada caso, guardar una captura en `docs/evidencias/pruebas/` con el nombre indicado en `docs/07-pruebas.md` y actualizar ahí su estado.

## Nota para exposición

El QR guarda únicamente el identificador del lote, no los datos personales ni la información completa del producto. La app resuelve los datos desde SQLite; por eso la consulta local puede funcionar sin conexión una vez que los registros existen en el dispositivo.
