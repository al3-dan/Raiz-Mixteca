# Requisitos del sistema RaizMixteca

## 1. Requisitos funcionales

| ID | Requisito | Prioridad |
|---|---|---|
| RF-01 | El sistema deberá permitir registrar productores. | Alta |
| RF-02 | El sistema deberá permitir modificar los datos de un productor. | Media |
| RF-03 | El sistema deberá permitir registrar productos. | Alta |
| RF-04 | El sistema deberá permitir registrar lotes. | Alta |
| RF-05 | El sistema deberá asociar un lote con un producto. | Alta |
| RF-06 | El sistema deberá permitir asociar fotografías a un registro. | Media |
| RF-07 | El sistema deberá permitir registrar información del proceso de producción. | Media |
| RF-08 | El sistema deberá generar un identificador único para cada lote. | Alta |
| RF-09 | El sistema deberá generar un código QR asociado al lote. | Alta |
| RF-10 | El sistema deberá permitir escanear códigos QR. | Alta |
| RF-11 | El sistema deberá mostrar información pública asociada al código QR. | Alta |
| RF-12 | El sistema deberá permitir almacenar información localmente. | Alta |
| RF-13 | El sistema deberá permitir consultar información previamente almacenada sin conexión a Internet. | Alta |

## 2. Requisitos no funcionales

### RNF-01 — Funcionamiento sin conexión

La aplicación deberá permitir realizar las funciones principales de registro sin requerir una conexión permanente a Internet.

### RNF-02 — Usabilidad

La interfaz deberá permitir que los usuarios realicen las funciones principales mediante formularios y una navegación sencilla.

### RNF-03 — Persistencia

La información registrada deberá conservarse en el almacenamiento local del dispositivo.

### RNF-04 — Privacidad

El sistema deberá diferenciar entre información de uso interno y aquella información que el productor decida mostrar públicamente al consumidor.

### RNF-05 — Escalabilidad

La arquitectura deberá permitir incorporar posteriormente sincronización con un servidor y una base de datos central.

## 3. Información que necesita almacenar el sistema

A partir de los requisitos definidos, el sistema deberá manejar información relacionada con:

- Productores.
- Productos.
- Lotes.
- Fotografías.
- Información del proceso de producción.
- Identificadores de lote.
- Información asociada a códigos QR.
- Datos públicos de contacto del productor.

## 4. Tecnologías consideradas

Para la primera versión del proyecto se contempla almacenamiento local mediante SQLite.

Una arquitectura con API REST y PostgreSQL podrá considerarse como una evolución posterior del sistema y no se presenta como parte implementada del MVP.
