# Arquitectura

Describe el código actual de `lib/`. Las decisiones de servicios externos vienen del issue #46.

## Capas (feature-first)

```text
presentation (widgets + Cubit)  →  domain (contratos)  →  data (datasources + repositorio)
```

- Regla: los widgets y Cubits de `presentation/` no importan `cloud_firestore`, `firebase_auth`, `http` ni SDKs de mapas.
- Inyección de dependencias: `lib/src/core/di/injection.dart` con `get_it`.
- Estados de pantalla: `lib/src/core/widgets/ui_state.dart` (`UiState`) y `UiStateView`; errores y vacíos con `MensajeEstado`.
- Estado de la app: `flutter_bloc`. La sesión global es `AuthSessionCubit`; cada formulario tiene su propio Cubit.

Nota: `core/services/` sigue vacío; aquí irán `CamaraService`, `UbicacionService`, etc. La decisión vigente del issue #46 (ver [servicios.md](servicios.md)) es Google Maps SDK y Google Routes API, ambos pendientes.

## Árbol real de `lib/`

```text
lib/
  main.dart
  firebase_options.dart          # local (.gitignore); plantilla: firebase_options.example.dart
  src/
    app/app.dart                 # BlocProvider de la sesión + MaterialApp.router + AppTheme
    core/
      di/injection.dart          # Firestore, Auth, AuthSessionCubit, AppRouter
      errors/app_failure.dart    # jerarquía sellada de fallos con mensaje de usuario
      firebase/firebase_bootstrap.dart
      router/app_router.dart · app_routes.dart · stream_listenable.dart
      theme/                     # AppColors, AppSpacing, AppRadii, AppTheme
      widgets/                   # UiState, UiStateView, MensajeEstado
      logging/app_logger.dart
      services/                  # vacío; aquí irán CamaraService, UbicacionService, etc.
    features/
      auth/          domain | data | presentation  (activo: login, registro, verificación, sesión)
      home/          presentation/                 (activo: saludo y cerrar sesión; sin domain/data aún)
      profile/       domain | data | presentation  (stub: solo .gitkeep)
      routes_map/    domain | data | presentation  (stub: solo .gitkeep)
      reservations/  domain | data | presentation  (stub: solo .gitkeep)
      boarding/      domain | data | presentation  (stub: solo .gitkeep)
      trip/          domain | data | presentation  (stub: solo .gitkeep)
      incidents/     domain | data | presentation  (stub: solo .gitkeep)
      operator/      domain | data | presentation  (stub: solo .gitkeep)
      admin/         domain | data | presentation  (stub: solo .gitkeep; admin oficial será panel web)
```

Cada feature tiene carpetas `domain/`, `data/` y `presentation/` (las stubs solo con `.gitkeep`; `home` solo tiene `presentation/` por ahora).

## Navegación

| Archivo | Contenido |
|---------|-----------|
| `lib/src/core/router/app_routes.dart` | `/cargando`, `/login`, `/registro`, `/verificacion`, `/inicio` |
| `lib/src/core/router/app_router.dart` | `GoRouter` con redirección según `AuthSessionState` |
| `lib/src/core/router/stream_listenable.dart` | Adapta el stream del Cubit a `refreshListenable` |

Redirecciones: sin sesión solo se permiten login y registro; cuenta pendiente o rechazada va a verificación; cuenta aprobada entra a inicio y no puede volver a las pantallas de auth. Las rutas específicas por rol (operador) están pendientes.

## Arranque

```text
main → configureDependencies() → FirebaseBootstrap.initialize() → runApp(TransporteApp)
```

`FirebaseBootstrap` (`lib/src/core/firebase/firebase_bootstrap.dart`) lee `USE_FIREBASE` desde `--dart-define` o `env/*.json`. Si es `false`, no llama a `Firebase.initializeApp`; `injection.dart` registra entonces `UnavailableAuthRepository`, que responde con un fallo claro y hace que el login muestre un aviso.

## Datos (Firestore)

Reglas en `firebase/firestore.rules`; campos en [arquitectura-y-datos/modelo-firestore.md](arquitectura-y-datos/modelo-firestore.md).

| Colección | Id | Notas |
|-----------|----|-------|
| usuarios | uid | rol, estadoVerificacion |
| rutas, paradas, salidas | automático | catálogo y operación |
| reservas | `{salidaId}_{uid}` | transacción de cupo |
| pagos | automático | solo Cloud Functions escribe `aprobado` |
| reportes | automático | incidencias |

Subcolecciones: `usuarios/{uid}/dispositivos` y `salidas/{id}/privado/qr`.

El perfil (permanente) se separa de reservas y pagos (operación).

## Backend en el repositorio y pendiente

```text
firebase/firestore.rules · firestore.indexes.json · storage.rules   # hecho
functions/          # TypeScript: pagos, QR, notificaciones (pendiente)
admin-web/          # panel de administración (pendiente)
```

## Configuración local

| Archivo | Versionado | Uso |
|---------|------------|-----|
| `env/example.json` | Sí | Plantilla de `USE_FIREBASE` |
| `env/dev.json` | No | Defines de arranque |
| `android/local.properties` | No | `MAPS_API_KEY` (futuro) |
| `android/app/google-services.json` | No | Firebase para Android |
| `lib/firebase_options.dart` | No | Generado por FlutterFire |

Proyecto Firebase `utebus-4435b` (`.firebaserc` y `firebase.json` en la raíz). Detalle del backend: [arquitectura-y-datos/README.md](arquitectura-y-datos/README.md). Qué está hecho y qué falta: [estado.md](estado.md).

## Responsividad

Tema Material 3 en `AppTheme` con `google_fonts` (Source Sans 3). Al agregar pantallas: `Theme.of(context)`, `LayoutBuilder` o breakpoints para móvil; probar en emulador pequeño y mediano; evitar anchos fijos en píxeles para el contenido principal.

## Repositorio

Trabajar solo en `lib/` de la raíz.
