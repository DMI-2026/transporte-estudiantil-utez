# Pantalla: Rutas y mapa (`/rutas`)

Permite consultar el catálogo de rutas en Firestore. El mapa, paradas en tiempo real y ubicación del usuario siguen pendientes.

---

## Ruta y acceso

| Atributo | Valor |
|----------|-------|
| Ruta | `/rutas` |
| Rol | Estudiante (navegación principal); operador y admin pueden llegar desde sus placeholders |
| Acceso | Solo con sesión aprobada |
| Layout | Lista de rutas y acción de prueba de permisos |
| Registro de ruta | `apps/mobile/lib/src/core/router/app_routes.dart` |

---

## Estado de implementación

**Activo (lista)** — Lee la colección `rutas` y ofrece “Agregar ruta de prueba”. Estudiante y operador reciben permiso denegado al crear; solo el rol administrador en reglas puede escribir. Google Maps, paradas cercanas y polilínea: pendientes.

---

## Diseño y secciones

- Lista de rutas activas (nombre y metadatos visibles).
- Botón para intentar crear una ruta de prueba (valida reglas).
- Mapa con Google Maps SDK (pendiente).
- Ubicación bajo demanda para la parada más cercana (pendiente).
- Polilínea de la ruta (calculada por Google Routes API desde el panel admin, pendiente en cliente).

---

## Archivos involucrados

```text
lib/src/features/routes_map/
├── domain/
│   ├── entities/bus_route.dart
│   └── repositories/routes_repository.dart
├── data/
│   ├── datasources/routes_remote_datasource.dart
│   ├── datasources/firestore_routes_remote_datasource.dart
│   └── repositories/routes_repository_impl.dart
├── presentation/
│   ├── routes_cubit.dart
│   ├── routes_state.dart
│   └── routes_page.dart
test/
└── features/routes_map/
    └── routes_cubit_test.dart
```

Dependencias en `apps/mobile/lib/src/core/di/injection.dart`.

---

## Datos y contratos

| Colección | Documento | Campos relevantes |
|-----------|-----------|-------------------|
| `rutas` | automático | Catálogo de rutas |
| `paradas` | automático | Paradas de cada ruta (lectura futura) |
| `salidas` | automático | `programada`, `enCurso`, `finalizada`, `cancelada` |

---

## Guía de construcción (pendiente mapa)

1. Mantener el patrón de capas actual (`RoutesRepository`, `RoutesCubit`).
2. Agregar dependencias: `google_maps_flutter`, `geolocator`, `permission_handler`.
3. Extender el repositorio con `paradas` y `salidas`.
4. Integrar Google Maps SDK y permisos en `AndroidManifest.xml` / `Info.plist`.
5. Ampliar pruebas en `apps/mobile/test/features/routes_map/`.

---

## Documentación relacionada

- [../estado.md](../estado.md) — Feature `routes_map` (lista hecha, mapa pendiente).
- [../modulos/estudiante.md](../modulos/estudiante.md) — Módulo estudiante, sección routes_map.
- [../modulos/funcionalidades/rutas.md](../modulos/funcionalidades/rutas.md) — Reglas de rutas y paradas.
- [../03-integraciones.md](../03-integraciones.md) — Google Maps SDK y Google Routes API (pendientes).