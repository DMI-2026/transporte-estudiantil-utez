# Transporte exclusivo estudiantil UTEZ

Aplicación Flutter para que estudiantes de la UTEZ reserven asiento en combis aliadas, sigan la unidad y aborden con un código QR. El backend previsto es Firebase. El cálculo de rutas y de ETA es OpenRouteService, y el mapa es Google Maps.

Este repositorio contiene la arquitectura base: capas `data`, `domain` y `presentation`, inyección con get_it, navegación con go_router y el tema institucional.

## Documentación

- [Enunciado del proyecto](docs/proyecto-integrador.md)
- [Manual de desarrollador](docs/manual-desarrollador.md)

## Requisitos

- Flutter 3.47.7 (Dart 3.13.5)
- Android SDK para emulador Android
- Xcode para simulador iOS

## Arranque

```bash
flutter pub get
flutter run
```

La pantalla de inicio abre con el tema de la UTEZ. Firebase no se inicializa hasta configurar el proyecto nativo. Los pasos, las variables de `env/` y el flujo de ramas están en el manual.

## Estructura

```
lib/
  main.dart
  src/
    app/            MaterialApp y tema
    core/           dependencias, router, Firebase, logger y tema
    features/       auth, home, routes_map, reservations, boarding,
                    trip, incidents, operator, admin, profile
```

Cada feature se parte en `data`, `domain` y `presentation`.

## Comprobaciones

```bash
flutter analyze
flutter test
```
