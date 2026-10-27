# Módulo: administrador

La implementación canónica es el panel web `admin-web/` (pendiente), junto con las reglas de Firebase y las Cloud Functions (Alison y Jesús).

`lib/src/features/admin/` es opcional, un prototipo; no duplicar lógica de administración en Flutter salvo issue explícito.

## Responsabilidades

- Verificar cuentas de estudiantes y operadores.
- Mantener el catálogo de rutas y paradas; programar salidas.
- Monitorear reservas e incidencias.

## Dónde implementar

| Capa | Ruta en el repositorio | Estado |
|------|------------------------|--------|
| Reglas de Firestore y Storage | `firebase/` | Hecho; mantenimiento continuo |
| Webhooks de pago, QR, notificaciones | `functions/` | Pendiente |
| Interfaz de administración | `admin-web/` | Pendiente |

Datos y colecciones: [arquitectura.md](../arquitectura.md). Pagos: [funcionalidades/pagos.md](funcionalidades/pagos.md).
