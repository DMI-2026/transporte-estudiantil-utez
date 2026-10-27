# Módulos: índice

## Antes de abrir un issue de feature

1. Leer [estado.md](../estado.md) para saber qué está hecho en Firebase y qué falta en Flutter.
2. Tener la configuración local de Firebase si el issue toca red: [arquitectura.md, sección Configuración local](../arquitectura.md#configuración-local).
3. El feature `auth` ya está hecho y es la referencia de estructura, pruebas y fakes. Sin sesión no aplican las reglas de negocio de Firestore.

Elegir un solo documento según el issue:

| Si el issue toca | Leer |
|------------------|------|
| Login, perfil, inicio, mapa del estudiante, viaje, incidencias | [estudiante.md](estudiante.md) |
| Salidas, GPS del operador, lista de abordaje, mostrar QR | [operador.md](operador.md) |
| Panel de administración, verificación de cuentas, catálogo | [administrador.md](administrador.md) |
| Reglas de reserva y cupo | [funcionalidades/reservas.md](funcionalidades/reservas.md) |
| Rutas, paradas, polilínea | [funcionalidades/rutas.md](funcionalidades/rutas.md) |
| Mercado Pago, estados del pago | [funcionalidades/pagos.md](funcionalidades/pagos.md) |
| Secreto del QR, validación de abordaje | [funcionalidades/qr.md](funcionalidades/qr.md) |

## Features (código)

| Feature | Ruta | Rol | Estado | Qué cubre |
|---------|------|-----|--------|-----------|
| auth | `lib/src/features/auth/` | Estudiante y operador | activo | Registro, acceso, verificación de cuenta, sesión |
| home | `lib/src/features/home/` | Estudiante | activo | Pantalla de inicio (hoy saludo; después próxima salida) |
| profile | `lib/src/features/profile/` | Estudiante | stub | Perfil, privacidad, baja de cuenta |
| routes_map | `lib/src/features/routes_map/` | Estudiante | stub | Consultar rutas y paradas; mapa; ubicación del operador |
| reservations | `lib/src/features/reservations/` | Estudiante | stub | Reservar asiento |
| boarding | `lib/src/features/boarding/` | Estudiante | stub | Abordar con QR |
| trip | `lib/src/features/trip/` | Estudiante | stub | Seguimiento del viaje y tiempo estimado |
| incidents | `lib/src/features/incidents/` | Estudiante | stub | Reportar incidencias |
| operator | `lib/src/features/operator/` | Operador | stub | Salidas, ruta, lista de abordaje, QR |
| admin | `lib/src/features/admin/` | Administrador | stub | Verificación y catálogo; la implementación oficial será el panel web |

Al asignar un issue: localizar la fila, abrir el documento del rol o funcionalidad, buscar en `lib/src/features/<nombre>/` y repasar [reglas-desarrollo.md](../reglas-desarrollo.md).

## Estados de dominio

- Usuario: `pendiente`, `aprobada`, `rechazada`
- Salida: `programada`, `enCurso`, `finalizada`, `cancelada`
- Reserva: `pendientePago`, `reservada`, `cancelada`, `abordada`
- Reporte: `abierto`, `enRevision`, `cerrado`

Trazabilidad con el enunciado: [referencia-dmi.md](../referencia-dmi.md).
