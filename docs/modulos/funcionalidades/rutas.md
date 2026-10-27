# Funcionalidad: rutas y mapa

Feature: `lib/src/features/routes_map/`. Estado: pendiente. Cubre consultar rutas y paradas, y seguir la combi en el mapa.

## Datos

- Colecciones `rutas`, `paradas` y `salidas` (catálogo y operación).
- La polilínea se guarda en Firestore; la calcula Google Routes API al crear o editar la ruta desde el panel de administración (pendiente).

## App del estudiante

- Mapa con paradas y salidas activas.
- Ubicación solo bajo demanda, para encontrar la parada cercana.

## App del operador

- Transmite su ubicación mientras la salida está en `enCurso`; ver [operador.md](../operador.md).

Integración con Google Maps: [servicios.md](../../servicios.md).
