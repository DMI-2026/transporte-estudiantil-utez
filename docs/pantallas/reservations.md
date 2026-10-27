# Pantalla: Reservas (`/reservas`)

Permite al estudiante reservar un asiento en una salida con control de cupo mediante transacción de Firestore.

---

## Ruta y acceso

| Atributo | Valor |
|----------|-------|
| Ruta | `/reservas` |
| Rol | Estudiante |
| Acceso | Solo con sesión aprobada |
| Layout | Pantalla de selección de salida y asiento |
| Registro de ruta | `lib/src/core/router/app_routes.dart` |

---

## Estado de implementación

**Stub** — Carpeta de feature creada, sin código de negocio.

---

## Diseño y secciones

- Lista de salidas disponibles con cupos.
- Selección de asiento en la combi.
- Resumen de reserva y botón de confirmar.
- Integración con pagos (Mercado Pago, pendiente).
- Estados de reserva: `pendientePago`, `reservada`, `cancelada`, `abordada`.

---

## Archivos involucrados

```text
lib/src/features/reservations/
├── domain/
│   ├── Reserva.dart                 # Entidad (stub)
│   └── ReservationsRepository.dart  # Contrato (stub)
├── data/
│   └── ReservationsRepositoryImpl.dart # Implementación (stub)
├── presentation/
│   ├── reservations_cubit.dart      # Cubit (stub)
│   ├── reservations_state.dart      # Estado (stub)
│   └── reservations_page.dart       # Widget (stub)
test/
└── features/reservations/
    └── reservations_cubit_test.dart # Pruebas (stub)
```

---

## Datos y contratos

| Colección | Documento | Campos relevantes |
|-----------|-----------|-------------------|
| `reservas` | `{salidaId}_{uid}` | `pendientePago`, `reservada`, `cancelada`, `abordada`, `creadaEn` |
| `salidas` | automático | Cupos disponibles |

---

## Guía de construcción

1. Copiar el patrón de capas de `auth`.
2. Implementar `ReservationsRepository` con transacción de cupo en Firestore.
3. Implementar `ReservationsCubit` con estados de carga, éxito y error.
4. Crear `ReservationsPage` con selección de salida y asiento.
5. Integrar pagos mediante Cloud Functions (Mercado Pago, pendiente).
6. Registrar dependencias en `injection.dart`.
7. Escribir pruebas en `test/features/reservations/`.
8. Registrar la ruta en `app_routes.dart`.

---

## Documentación relacionada

- [../estado.md](../estado.md) — Feature `reservations`: stub.
- [../modulos/estudiante.md](../modulos/estudiante.md) — Módulo estudiante, sección reservations.
- [../modulos/funcionalidades/reservas.md](../modulos/funcionalidades/reservas.md) — Reglas de reserva y cupo.
- [../modulos/funcionalidades/pagos.md](../modulos/funcionalidades/pagos.md) — Mercado Pago y estados del pago.
