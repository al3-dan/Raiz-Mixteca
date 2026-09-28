# Bitácora del proyecto RaízMixteca

## Información general

**Proyecto:** RaízMixteca  
**Fecha de inicio:** Septiembre de 2026  
**Fecha de presentación:** 2 de octubre de 2026

---

## Registro de actividades

### 27/09/2026

#### Actividades realizadas
- Organización de la documentación del proyecto.
- Creación de la estructura de evidencias en el repositorio.
- Creación de las carpetas para planeación, desarrollo, pruebas y presentación.
- Preparación de la bitácora del proyecto.
- Implementación del flujo de códigos QR en la app: generación del identificador `LOT-000001`, validación del formato, pantalla de lectura, pantalla pública y acceso desde detalle del lote.
- Registro de la dependencia `qr_flutter` y `mobile_scanner` en el proyecto.
- Ajuste del flujo de creación de lotes para generar el código único automáticamente desde el último id disponible.

#### Integrantes
- Integrante 1: Diego Fidel Sosa Cruz
- Integrante 2: Daniel Alejandro Lopez Camarillo
- Integrante 3: Felix Angel Garcia Garcia
- Integrante 4: Luis Alexis Morales Jose

#### Herramientas utilizadas
- GitHub
- Git
- ClickUp
- Flutter
- Visual Studio Code

#### Problemas encontrados
- El primer intento de pruebas fue sin teléfono conectado. En el reintento, Flutter detectó el teléfono Android 16 RMX3867, pero no pudo compilar ni instalar la app porque el NDK `28.2.13676358` está incompleto y `sdkmanager` falla con exit code `-1073740791` usando Java 25.

#### Soluciones aplicadas
- Se ejecutaron pruebas automatizadas para validación del identificador y análisis estático para revisar el código QR.
- Se registró por separado qué pruebas funcionales siguen pendientes para no reportar resultados manuales no ejecutados.
- Se repitió la detección del dispositivo y se intentó el arranque en Android; se localizó la instalación incompleta del NDK como bloqueo previo a las pruebas de cámara.

#### Evidencias
- Verificación automatizada: `flutter test` (3 tests aprobados) y `flutter analyze` (sin incidencias), 27/09/2026.
- El registro por caso y las capturas pendientes se encuentran en `docs/07-pruebas.md` y `docs/evidencias/pruebas/`.

#### Pendientes
- Ejecutar P-01 a P-07 en teléfono/emulador y guardar las capturas reales en `docs/evidencias/pruebas/`.
- Confirmar en dispositivo que el QR compartido como PNG se decodifica y que el escaneo muestra la consulta pública.
- Reparar la instalación del NDK `28.2.13676358` y volver a compilar con una cadena Java/Android SDK compatible.
