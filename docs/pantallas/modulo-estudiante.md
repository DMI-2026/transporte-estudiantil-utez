# Módulo estudiante: pantallas del Figma "01 App Estudiante"

Pantallas del rol estudiante agregadas en la rama `feat/estudiante`. Solo frontend: los datos vienen de fuentes de **demostración en memoria** (sin Firebase) registradas en `apps/mobile/lib/src/core/di/injection.dart` (`_configureEstudiante`). Quien haga el backend cambia solo esa fuente de datos; las pantallas y los Cubits no cambian.

## Pantallas y rutas

| Figma | Pantalla | Ruta | Archivo |
|-------|----------|------|---------|
| 08 | Elegir salida y reservar | `/reservas/salidas` | `features/reservations/presentation/salidas/salidas_page.dart` |
| 09 / 19 | Mis reservas (pestaña) | `/reservas` | `features/reservations/presentation/mis_reservas/mis_reservas_page.dart` |
| 16 | Reserva confirmada | `/reservas/confirmada/:folio` | `features/reservations/presentation/detalle/reserva_confirmada_page.dart` |
| 17 | Cancelar reserva | `/reservas/cancelar/:folio` | `features/reservations/presentation/cancelar/cancelar_reserva_page.dart` |
| 10 | Pase de abordaje (QR) | `/abordaje/:folio` | `features/boarding/presentation/qr_abordaje_page.dart` |
| 11 | Viaje en curso | `/viaje/:folio` | `features/trip/presentation/viaje_en_curso_page.dart` |
| 12 | Reportar incidente | `/incidencias?referencia=` | `features/incidents/presentation/reportar/reportar_incidente_page.dart` |
| 13 | Mis reportes | `/incidencias/mis-reportes` | `features/incidents/presentation/mis_reportes/mis_reportes_page.dart` |
| 14 | Mi perfil (pestaña) | `/perfil` | `features/profile/presentation/perfil/perfil_page.dart` |
| 15 | Ajustes (notificaciones, permisos, privacidad) | `/perfil/ajustes` | `features/profile/presentation/ajustes/ajustes_page.dart` |
| 05 | Aviso de privacidad (consulta) | `/perfil/aviso-privacidad` | `features/profile/presentation/privacidad/aviso_privacidad_page.dart` |

No se tocaron las pantallas que ya existían: login, registro y verificación (`auth`), Inicio (`home`) y Rutas (`routes_map`).

## Qué se agregó en archivos existentes (solo líneas nuevas)

- `app_routes.dart`: constantes de las rutas de arriba.
- `app_router.dart`: `...studentRoutes()` (definidas en `core/router/student_routes.dart`).
- `injection.dart`: `_configureEstudiante()` con los repositorios de demostración.
- `app.dart`: `StudentProviders` expone esos repositorios al árbol (`context.read`).
- `student_bottom_nav.dart`: pestañas Reservas y Perfil.
- `pubspec.yaml`: `qr_flutter` para el pase de abordaje.

## Estados y reglas cubiertas

- Cargando, datos, vacío y error con reintentar en cada pantalla con datos (`UiState` + `UiStateView`, C-11).
- Validación en el cliente: reporte (tipo, salida, 10 a 500 caracteres) y contacto del perfil (teléfono de 10 dígitos).
- Explicación previa antes del permiso de cámara al adjuntar evidencia; sección de permisos en Ajustes.
- Mensajes de usuario, nunca errores técnicos (`AppFailure`).

## Pendiente (fuera del alcance de frontend)

| Qué | Issue |
|-----|-------|
| Reservas en Firestore con transacción de cupo y pago real | #9 |
| QR firmado por Cloud Function y escaneo del operador | #11, #13 |
| Ubicación y ETA reales (hoy son ilustrativas) | #12, #14 |
| Reportes en Firestore y evidencia con cámara real | #15, #16 |
| Perfil y preferencias en Firestore | #18 |

## Datos de demostración

Folio activo `UTEZ-1048` (SAL-001, Combi 01). La salida SAL-003 está llena para probar ese caso. El pago se aprueba al instante y el importe ($20.00 MXN) no es tarifa oficial.
