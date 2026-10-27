# Servicios e integraciones

Estados: **Hecho** (en el repositorio y verificado) · **Local** (configurado en cada máquina, no versionado) · **Pendiente** (acordado, aún no en código) · **Propuesto** (requiere aprobación) · **No usar**. Detalle: [README, sección Estados de decisión](README.md#estados-de-decisión).

## Issue #46: arquitectura y servicios externos

Objetivo del issue: definir la arquitectura Flutter y los servicios de Firebase y externos, y documentarlos.

Estado en el repositorio: arquitectura base hecha; backend Firestore y Storage hecho en `firebase/`; feature `auth` completo con repositorio, Cubits y sesión; las demás features siguen pendientes.

| Decisión | Elección | Estado |
|----------|----------|--------|
| Arquitectura de la app | Features con capas domain, data y presentation; inyección con `get_it` | Hecho |
| Navegación | `go_router` con cinco rutas y redirección por sesión (`app_router.dart`) | Hecho |
| Backend | Firebase, sin API REST propia | Hecho |
| Autenticación | Firebase Auth con correo y contraseña | Hecho (`firebase_auth` + feature `auth`) |
| Base de datos | Cloud Firestore | Hecho (`cloud_firestore`; repositorio de `usuarios`; los demás pendientes) |
| Archivos | Cloud Storage | Hecho en reglas y bucket; pendiente el paquete `firebase_storage` en Flutter |
| Notificaciones push | Firebase Cloud Messaging + Cloud Functions | Pendiente |
| Mapa en la app | Google Maps SDK (`google_maps_flutter`) | Pendiente |
| Rutas y tiempo estimado | Google Routes API, llamada desde servidor o panel admin | Pendiente |
| Pagos | Mercado Pago Checkout Pro con webhooks en Cloud Functions | Pendiente |
| Administración | Panel web sobre el mismo Firebase | Pendiente (carpeta `admin-web/`) |
| Estado de UI | `flutter_bloc` + `UiState` | Hecho (auth y core) |

Compatibilidad verificada: Flutter SDK `>=3.13.3`; las dependencias de `pubspec.yaml` resuelven con `flutter pub get`. Storage, Functions y Maps en producción requieren el plan Blaze de Firebase.

## Dependencias Flutter (`pubspec.yaml`)

| Paquete | Versión declarada | Estado |
|---------|-------------------|--------|
| flutter | sdk | Hecho |
| go_router | ^18.1.1 | Hecho, en uso |
| get_it | ^9.3.0 | Hecho, en uso |
| firebase_core | ^5.0.0 | Hecho, arranque |
| cloud_firestore | ^7.0.0 | Hecho, inyección de dependencias |
| google_fonts | ^6.3.2 | Hecho, tema |
| cupertino_icons | ^1.0.8 | Hecho |
| firebase_auth | ^7.0.0 | Hecho, autenticación |
| flutter_bloc | ^9.1.1 | Hecho, Cubits |
| equatable | ^2.0.7 | Hecho, estados de Bloc |
| firebase_storage | — | Pendiente |
| firebase_messaging | — | Pendiente |
| google_maps_flutter | — | Pendiente |
| geolocator, permission_handler | — | Pendiente (ubicación) |
| image_picker, mobile_scanner | — | Pendiente (credencial y QR) |
| flutter_local_notifications | — | Pendiente |
| connectivity_plus | — | Pendiente (modo sin conexión) |
| cloud_functions (cliente) | — | Pendiente (funciones callable) |

## Firebase (proyecto `utebus-4435b`)

| Servicio | Estado | Notas |
|----------|--------|-------|
| Core | Hecho | `firebase_bootstrap.dart`; bandera `USE_FIREBASE` |
| Firestore | Hecho | Reglas, índices y datos demo en la nube; repositorio de `usuarios` en la app, los demás pendientes |
| Authentication | Hecho en la app; Local en consola | Habilitar el proveedor correo y contraseña en la consola de Firebase |
| Storage | Hecho | Bucket `utebus-4435b.firebasestorage.app`; `credenciales/{uid}/`, `documentacion/publico/`, `documentacion/{uid}/`, `reportes/{uid}/` |
| Cloud Functions | Pendiente | Pagos, QR, notificaciones; carpeta `functions/` |
| Emuladores | Pendiente | Carpeta `firebase/tests/` no existe aún; pruebas de reglas contra emulador local pendientes |

Nunca commitear: `google-services.json`, `GoogleService-Info.plist`, `lib/firebase_options.dart`, `env/dev.json`, claves de Mercado Pago o Google Routes, service accounts.

## APIs externas (pendientes)

| API | Uso | Dónde se llama |
|-----|-----|----------------|
| Google Maps SDK | Mapa y marcadores | Flutter: `routes_map`, `trip` |
| Google Routes API | Polilínea y tiempo estimado | Panel admin o Cloud Functions |
| Mercado Pago | Checkout y webhook | Solo Cloud Functions |

El cliente Flutter no marca pagos como aprobados ni incluye llaves de Routes o Mercado Pago.

## Servicios de dispositivo (pendientes, en `lib/src/core/services/`)

Un servicio por capacidad, con interfaz para poder sustituirlo por un fake en pruebas.

| Servicio | Para qué | Paquete previsto |
|----------|----------|------------------|
| CamaraService | Credencial del estudiante, foto de incidencia | image_picker |
| UbicacionService | Parada cercana (estudiante), posición en recorrido (operador) | geolocator |
| NotificacionesService | Avisos locales | flutter_local_notifications |
| QR | Mostrar y escanear código de abordaje | mobile_scanner + qr_flutter |
| Push | Mensajes de Firebase Cloud Messaging | firebase_messaging |

## Verificación tras cambiar servicios

- Al agregar un paquete: `flutter pub get`, `.\scripts\check.ps1` y actualizar la tabla de dependencias en el mismo PR.
- Un issue del tipo #46 actualiza la sección correspondiente; no implementar todos los servicios en un solo PR.
