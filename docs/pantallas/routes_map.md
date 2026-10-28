# Pantalla: Rutas y mapa (`/rutas`)

Permite al estudiante consultar rutas, paradas y salidas activas, con mapa y ubicación bajo demanda para encontrar la parada más cercana.

---

## Ruta y acceso

| Atributo | Valor |
|----------|-------|
| Ruta | `/rutas` |
| Rol | Estudiante |
| Acceso | Solo con sesión aprobada |
| Layout | Pantalla con mapa y lista de rutas |
| Registro de ruta | `lib/src/core/router/app_routes.dart` |

---

## Estado de implementación

**Stub** — Carpeta de feature creada, sin código de negocio.

---

## Diseño y secciones

- Mapa con Google Maps SDK (pendiente).
- Lista de rutas activas con paradas.
- Ubicación bajo demanda para la parada más cercana.
- Polilínea de la ruta (calculada por Google Routes API desde el panel admin).

---

## Archivos involucrados

```text
lib/src/features/routes_map/
├── domain/
│   ├── Ruta.dart                    # Entidad (stub)
│   ├── Parada.dart                  # Entidad (stub)
│   └── RoutesMapRepository.dart     # Contrato (stub)
├── data/
│   └── RoutesMapRepositoryImpl.dart # Implementación (stub)
├── presentation/
│   ├── routes_map_cubit.dart        # Cubit (stub)
│   ├── routes_map_state.dart        # Estado (stub)
│   └── routes_map_page.dart         # Widget (stub)
test/
└── features/routes_map/
    └── routes_map_cubit_test.dart   # Pruebas (stub)
```

---

## Datos y contratos

| Colección | Documento | Campos relevantes |
|-----------|-----------|-------------------|
| `rutas` | automático | Catálogo de rutas |
| `paradas` | automático | Paradas de cada ruta |
| `salidas` | automático | `programada`, `enCurso`, `finalizada`, `cancelada` |

---

## Guía de construcción

1. Copiar el patrón de capas de `auth`.
2. Agregar dependencias pendientes: `google_maps_flutter`, `geolocator`, `permission_handler`.
3. Implementar `RoutesMapRepository` con lectura de `rutas`, `paradas` y `salidas`.
4. Crear `RoutesMapCubit` con estados de carga, datos y error.
5. Integrar Google Maps SDK para mostrar mapa y marcadores.
6. Agregar permiso de ubicación en `AndroidManifest.xml` e `Info.plist`.
7. Registrar dependencias en `injection.dart`.
8. Escribir pruebas en `test/features/routes_map/`.
9. Registrar la ruta en `app_routes.dart`.

---

## Documentación relacionada

- [../estado.md](../estado.md) — Feature `routes_map`: stub.
- [../modulos/estudiante.md](../modulos/estudiante.md) — Módulo estudiante, sección routes_map.
- [../modulos/funcionalidades/rutas.md](../modulos/funcionalidades/rutas.md) — Reglas de rutas y paradas.
- [../servicios.md](../servicios.md) — Google Maps SDK y Google Routes API (pendientes).
