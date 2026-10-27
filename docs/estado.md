# Estado del proyecto: hecho y pendiente

Actualizado según el repositorio y el proyecto Firebase `utebus-4435b` (2026-10-27). Estados: [README, sección Estados de decisión](README.md#estados-de-decisión).

## Resumen

| Área | Estado | Notas |
|------|--------|-------|
| Arquitectura Flutter (capas, inyección de dependencias, router) | Hecho | Redirección por sesión y verificación |
| Autenticación: login, registro, perfil en Firestore, verificación | Hecho | `lib/src/features/auth/` |
| Estados de pantalla (`UiState`, `UiStateView`, `MensajeEstado`) | Hecho | `lib/src/core/widgets/` |
| Estado de UI con `flutter_bloc` (Cubits, incluida la sesión) | Hecho | `AuthSessionCubit`, `LoginCubit`, `RegisterCubit` |
| Firestore: modelo, reglas, índices, datos demo | Hecho | [arquitectura-y-datos/](arquitectura-y-datos/) |
| Storage: reglas y bucket | Hecho | |
| Sensor `check.ps1`, hook pre-commit, pruebas con fakes | Hecho | `flutter test` |
| Pruebas de reglas Firestore y Storage (`firebase/tests/`) | Hecho | Emulador local; `npm run test:emulator` |
| Prueba de integración del arranque (`integration_test/`) | Hecho | Flujo login y registro sin Firebase |
| Repositorios de las demás features | Pendiente | Copiar el patrón de `auth` |
| Cloud Functions | Pendiente | Pagos, QR, notificaciones |
| Panel web de administración | Pendiente | |
| Mapas, pagos, QR en la app | Pendiente | |

Conclusión: el equipo puede abrir issues de `profile`, `reservations`, `routes_map` y los demás módulos siguiendo el patrón de `auth`. Cada desarrollador debe completar la [configuración local](#configuración-local-de-cada-desarrollador) para probar contra Firebase.

## Hecho (no bloquea issues)

- Autenticación: login, registro (estudiante con correo `@utez.edu.mx`, operador con correo libre), documento `usuarios/{uid}`, cierre de sesión.
- Si al registrarse falla el guardado del perfil, la app cierra la sesión para no dejar una cuenta sin documento.
- Un rol o estado de verificación desconocido en Firestore se trata como perfil inválido; la app nunca asume un rol por defecto.
- Router: `/login`, `/registro`, `/verificacion`, `/inicio`, con redirección según el estado de la sesión.
- Modelo Firestore, reglas, índices y documentos de demostración `demo-*`.
- Scripts: `scripts/setup-local.ps1` (configuración local), `scripts/seed-firestore-prod.ps1` (datos demo con service account).
- `flutter analyze` y `flutter test` en verde mediante `scripts/check.ps1`.
- Pruebas de reglas contra el emulador (`firebase/tests/`) y prueba de integración del arranque (`integration_test/`).

## Configuración local de cada desarrollador

Nada de esto se versiona.

```powershell
dart pub global activate flutterfire_cli
# Agregar %LOCALAPPDATA%\Pub\Cache\bin al PATH y abrir una terminal nueva
.\scripts\setup-local.ps1
.\scripts\setup-local.ps1 -RunFlutterfire
# Colocar google-services.json en android/app/
```

| Requisito | Para qué sirve |
|-----------|----------------|
| `env/dev.json` | Define `USE_FIREBASE: true` |
| `lib/firebase_options.dart` | Generado por FlutterFire |
| `android/app/google-services.json` | Configuración de Firebase para Android |
| Proveedor "correo y contraseña" habilitado en la consola de Firebase | Permite el registro real |

Sin Firebase configurado, la app muestra el login con un aviso y no autentica.

## Siguiente oleada de issues

| Prioridad | Módulo | Qué falta |
|-----------|--------|-----------|
| 1 | `profile` | Perfil, avisos de notificaciones, eliminar cuenta (derechos ARCO) |
| 2 | `routes_map` | Google Maps y lectura de `rutas`, `paradas`, `salidas` |
| 3 | `reservations` | Reservas con transacción de cupo |
| 4 | Backend | `functions/` para QR, pagos y notificaciones |
| 5 | Administración | `admin-web/` con verificación de cuentas |

## Features en `lib/src/features/`

| Feature | Estado | Notas |
|---------|--------|-------|
| auth | activo | Login, registro, verificación, sesión |
| home | activo | Saludo y cierre de sesión |
| profile | stub | Siguiente después de auth |
| routes_map, reservations, boarding, trip, incidents, operator, admin | stub | Copiar las capas de `auth` |

## Comprobación rápida

```powershell
.\scripts\check.ps1
.\scripts\verify-activity.ps1 -Tipo feature -Feature auth
```
