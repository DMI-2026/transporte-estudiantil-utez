# Pantalla: Seguimiento del viaje (`/viaje`)

Permite al estudiante ver la combi en el mapa y el tiempo estimado de llegada a su parada.

---

## Ruta y acceso

| Atributo | Valor |
|----------|-------|
| Ruta | `/viaje` |
| Rol | Estudiante |
| Acceso | Solo con sesión aprobada y reserva activa |
| Layout | Pantalla con mapa en tiempo real |
| Registro de ruta | `lib/src/core/router/app_routes.dart` |

---

## Estado de implementación

**Stub** — Carpeta de feature creada, sin código de negocio.

---

## Diseño y secciones

- Mapa con la posición de la combi en tiempo real.
- Tiempo estimado de llegada a la parada del estudiante.
- Polilínea de la ruta (desde Google Routes API).
- Notificaciones push de aviso de salida y reserva (pendiente).

---

## Archivos involucrados

```text
lib/src/features/trip/
├── domain/
│   ├── Viaje.dart                   # Entidad (stub)
│   └── TripRepository.dart          # Contrato (stub)
├── data/
│   └── TripRepositoryImpl.dart      # Implementación (stub)
├── presentation/
│   ├── trip_cubit.dart              # Cubit (stub)
│   ├── trip_state.dart              # Estado (stub)
│   └── trip_page.dart               # Widget (stub)
test/
└── features/trip/
    └── trip_cubit_test.dart         # Pruebas (stub)
```

---

## Datos y contratos

| Colección | Documento | Campos relevantes |
|-----------|-----------|-------------------|
| `salidas` | automático | `enCurso`, posición del operador |
| `reservas` | `{salidaId}_{uid}` | Reserva activa del estudiante |

---

## Guía de construcción

1. Copiar el patrón de capas de `auth`.
2. Agregar dependencias pendientes: `google_maps_flutter`, `geolocator`, `firebase_messaging`.
3. Implementar `TripRepository` con lectura de posición de la salida en curso.
4. Crear `TripCubit` con estados de carga, datos y error.
5. Integrar Google Maps SDK para mostrar la combi y la polilínea.
6. Agregar permiso de ubicación en primer plano para el operador.
7. Registrar dependencias en `injection.dart`.
8. Escribir pruebas en `test/features/trip/`.
9. Registrar la ruta en `app_routes.dart`.

---

## Documentación relacionada

- [../estado.md](../estado.md) — Feature `trip`: stub.
- [../modulos/estudiante.md](../modulos/estudiante.md) — Módulo estudiante, sección trip.
- [../modulos/operador.md](../modulos/operador.md) — Módulo operador, sección salidas.
- [../servicios.md](../servicios.md) — Google Maps SDK, Google Routes API, Firebase Cloud Messaging (pendientes).
