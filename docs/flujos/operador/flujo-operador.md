# Flujo del Operador

Recorrido del operador desde que inicia sesión hasta completar un recorrido: ver salidas, lista de abordaje y validar QR.

---

## Diagrama de navegación

```
/operador (salidas asignadas)
        │
        ├─► /operador (detalle de salida: ruta y paradas)
        │         │
        │         └─► /operador (lista de abordaje con QR)
        │                   │
        │                   └─► Validar QR del estudiante
        │                         │
        │                         └─► Reserva pasa a abordada
        │
        └─► (ubicación en primer plano durante el recorrido)
```

---

## Pantallas involucradas

| Pantalla | Ruta | Estado | Propósito |
|----------|------|--------|-----------|
| Panel operador | `/operador` | Stub | Ver salidas, ruta, lista de abordaje, QR |

---

## Reglas de negocio

| Regla | Descripción |
|-------|-------------|
| Salidas del operador | Solo las salidas asignadas al operador autenticado |
| Lista de abordaje | Estudiantes con reserva `reservada` en la salida |
| Validación QR | Operador escanea o valida el QR del estudiante |
| Secreto QR | Vive en `salidas/{salidaId}/privado/qr`; cliente solo lee |
| Ubicación | Operador transmite posición en primer plano durante el recorrido |

---

## Archivos clave

- `lib/src/features/auth/presentation/auth_session_cubit.dart` — Sesión global y rol.
- `lib/src/core/router/app_routes.dart` — Rutas del operador.
- `lib/src/features/operator/presentation/` — Cubit del operador (stub).
- `lib/src/features/operator/data/` — Repositorio del operador (stub).

---

## Flujo paso a paso

1. Operador inicia sesión y llega a `/operador`.
2. Ve la lista de salidas asignadas para hoy.
3. Selecciona una salida para ver la ruta, paradas y lista de abordaje.
4. En la lista de abordaje, ve los estudiantes con reserva `reservada` y su QR.
5. Valida el QR de cada estudiante al subir a la combi; la reserva pasa a `abordada`.
6. Durante el recorrido, comparte su ubicación en primer plano.

---

## Documentación relacionada

- [../pantallas/operator.md](../pantallas/operator.md)
- [../modulos/operador.md](../modulos/operador.md)
- [../modulos/funcionalidades/qr.md](../modulos/funcionalidades/qr.md)
- [../modulos/funcionalidades/reservas.md](../modulos/funcionalidades/reservas.md)
- [../servicios.md](../servicios.md) — Cámara, ubicación, QR (pendientes).
- [../referencia-dmi.md](../referencia-dmi.md) — Historias de usuario del operador.
