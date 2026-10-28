# Flujo del Estudiante

Recorrido del estudiante desde que inicia sesión hasta completar un viaje: consultar rutas, reservar, abordar y seguir el viaje.

---

## Diagrama de navegación

```
/inicio (saludo, cerrar sesión)
        │
        ├─► /rutas (consultar rutas, paradas, salidas)
        │         │
        │         └─► /reservas (seleccionar salida y asiento)
        │                   │
        │                   └─► (pago pendiente, Cloud Functions)
        │                         │
        │                         └─► /abordaje (mostrar QR)
        │                               │
        │                               └─► /viaje (seguir combi, ETA)
        │
        └─► /perfil (datos, privacidad, notificaciones, eliminar cuenta)
        │
        └─► /incidencias (crear y consultar reportes)
```

---

## Pantallas involucradas

| Pantalla | Ruta | Estado | Propósito |
|----------|------|--------|-----------|
| Inicio | `/inicio` | Activo | Saludo y cierre de sesión |
| Rutas y mapa | `/rutas` | Stub | Consultar rutas, paradas, salidas |
| Reservas | `/reservas` | Stub | Reservar asiento con control de cupo |
| Abordaje con QR | `/abordaje` | Stub | Mostrar QR de abordaje |
| Viaje | `/viaje` | Stub | Seguir la combi y tiempo estimado |
| Perfil | `/perfil` | Stub | Datos, privacidad, notificaciones, ARCO |
| Incidencias | `/incidencias` | Stub | Crear y consultar reportes |

---

## Reglas de negocio

| Regla | Descripción |
|-------|-------------|
| Cupo de salida | Reserva con transacción de cupo en Firestore |
| Estado de reserva | `pendientePago` → `reservada` → `cancelada` o `abordada` |
| QR de abordaje | Secreto en `salidas/{salidaId}/privado/qr`; cliente solo lee |
| Perfil inválido | Rol o estado de verificación desconocido = acceso denegado |
| Pagos | El cliente nunca marca un pago como aprobado (Cloud Functions) |

---

## Archivos clave

- `lib/src/features/auth/presentation/auth_session_cubit.dart` — Sesión global.
- `lib/src/core/router/app_routes.dart` — Rutas del estudiante.
- `lib/src/features/<feature>/presentation/` — Cubits de cada feature.
- `lib/src/features/<feature>/data/` — Repositorios y datasources de Firestore.

---

## Flujo paso a paso

1. Estudiante inicia sesión y llega a `/inicio`.
2. Desde `/inicio`, navega a `/rutas` para ver salidas disponibles.
3. Selecciona una salida y asiento en `/reservas`; se crea la reserva con transacción de cupo.
4. (Pendiente) Pago mediante Mercado Pago en Cloud Functions; reserva pasa a `reservada`.
5. Antes de la salida, muestra el QR en `/abordaje`.
6. Operador valida el QR; reserva pasa a `abordada`.
7. Durante el recorrido, sigue la combi en `/viaje` con tiempo estimado de llegada.
8. Puede reportar incidencias en `/incidencias` y gestionar su perfil en `/perfil`.

---

## Documentación relacionada

- [../pantallas/home.md](../pantallas/home.md)
- [../pantallas/routes_map.md](../pantallas/routes_map.md)
- [../pantallas/reservations.md](../pantallas/reservations.md)
- [../pantallas/boarding.md](../pantallas/boarding.md)
- [../pantallas/trip.md](../pantallas/trip.md)
- [../pantallas/profile.md](../pantallas/profile.md)
- [../pantallas/incidents.md](../pantallas/incidents.md)
- [../modulos/estudiante.md](../modulos/estudiante.md)
- [../modulos/funcionalidades/reservas.md](../modulos/funcionalidades/reservas.md)
- [../modulos/funcionalidades/qr.md](../modulos/funcionalidades/qr.md)
- [../modulos/funcionalidades/pagos.md](../modulos/funcionalidades/pagos.md)
- [../referencia-dmi.md](../referencia-dmi.md) — Historias de usuario del estudiante.
