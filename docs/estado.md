# Estado del proyecto: hecho y pendiente

Actualizado según el repositorio y el proyecto Firebase `utebus-4435b` (2026-11-18). Estados: [README, sección Estados de decisión](README.md#estados-de-decisión).

## Resumen

| Área | Estado | Notas |
|------|--------|-------|
| Arquitectura Flutter (capas, inyección de dependencias, router) | Hecho | Redirección por sesión y verificación |
| Autenticación: login, registro, perfil en Firestore, verificación | Hecho | Contraseña mínima 8 caracteres; UI alineada al Figma (auth) |
| Estados de pantalla (`UiState`, `UiStateView`, `MensajeEstado`) | Hecho | `apps/mobile/lib/src/core/widgets/` |
| Estado de UI con `flutter_bloc` (Cubits, incluida la sesión) | Hecho | `AuthSessionCubit`, `LoginCubit`, `RegisterCubit` |
| Firestore: modelo, reglas, índices, datos demo | Hecho | [arquitectura-y-datos/](arquitectura-y-datos/) |
| Seed demo (Firestore + usuarios Auth) | Hecho | `scripts/seed-firestore.ps1` → `apps/firebase/tools/seed-demo-data.mjs` |
| Storage: reglas y bucket | Hecho | |
| `routes_map` (lista y permiso al crear) | Hecho (parcial) | Sin Google Maps ni paradas en mapa |
| `home` (saludo, navegación a rutas) | Hecho (parcial) | Sin próxima reserva ni ETA |
| Sensor `check.ps1`, hook pre-commit, pruebas con fakes | Hecho | `flutter test` |
| Pruebas de reglas Firestore y Storage (`apps/firebase/tests/`) | Pendiente | Carpeta aún no en repo o sin ejecutarse en CI |
| Prueba de integración del arranque (`apps/mobile/integration_test/`) | Hecho | Flujo login y registro sin Firebase real |
| Repositorios de las demás features | Pendiente | Copiar el patrón de `auth` y `routes_map` |
| Cloud Functions | Pendiente | Pagos, QR, notificaciones |
| Panel web de administración | Pendiente | |
| Mapas, pagos, QR en la app | Pendiente | |

Conclusión: el equipo puede abrir issues de `profile`, `reservations`, el mapa en `routes_map` y los demás módulos siguiendo el patrón de `auth`. Cada desarrollador debe completar la [configuración local](#configuración-local-de-cada-desarrollador) y, para probar login con cuentas demo, ejecutar el [seed](#datos-demo-en-firebase).

## Hecho (no bloquea issues)

- Autenticación: login, registro (estudiante con correo `@utez.edu.mx`, operador con correo libre), documento `usuarios/{uid}`, cierre de sesión.
- Si al registrarse falla el guardado del perfil, la app cierra la sesión para no dejar una cuenta sin documento.
- Un rol o estado de verificación desconocido en Firestore se trata como perfil inválido; la app nunca asume un rol por defecto.
- Router: `/login`, `/registro`, `/verificacion`, `/inicio`, `/rutas`, con redirección según el estado de la sesión.
- Modelo Firestore, reglas, índices y documentos de demostración `demo-*`.
- Scripts: `scripts/setup-local.ps1` (FlutterFire y `dev.json`); `scripts/seed-firestore.ps1` y `scripts/seed-firestore-prod.ps1` (datos + Auth demo).
- `flutter analyze` y `flutter test` en verde mediante `scripts/check.ps1`.
- Pantalla de rutas: lectura de `rutas` e intento de crear ruta de prueba (solo administrador en reglas).

## Configuración local de cada desarrollador

Nada de lo de esta tabla se versiona. Detalle y lista completa: [contribucion-repositorio.md](contribucion-repositorio.md).

```powershell
firebase login
.\scripts\setup-local.ps1 -RunFlutterfire
```

Ese comando activa FlutterFire CLI y escribe `firebase_options.dart`, `google-services.json` y `GoogleService-Info.plist`. `USE_FIREBASE` queda en `true` solo si los tres archivos existen y no son la plantilla.

| Requisito | Para qué sirve |
|-----------|----------------|
| `apps/mobile/env/dev.json` | Define `USE_FIREBASE: true` (copiar de `env/example.json`) |
| `apps/mobile/lib/firebase_options.dart` | Generado por FlutterFire |
| `apps/mobile/android/app/google-services.json` | Configuración de Firebase para Android |
| `apps/mobile/ios/Runner/GoogleService-Info.plist` | Configuración de Firebase para iOS |
| Proveedor **Correo/Contraseña** en Firebase Console | Obligatorio para login real; si está desactivado aparece `PASSWORD_LOGIN_DISABLED` |

Sin Firebase configurado, la app muestra el login con un aviso y no autentica.

### Datos demo en Firebase

Para las tres cuentas demo (misma contraseña `Pass123!`):

1. Colocar la service account en `apps/firebase/env/firebase-admin-sa.json` (no versionada), **o** tener `firebase login` activo.
2. Desde la raíz: `.\scripts\seed-firestore.ps1`

El script crea documentos en Firestore y usuarios en Authentication con uids fijos (`demo-estudiante-001`, etc.). Credenciales: [pantallas/auth/login.md](pantallas/auth/login.md).

Consola: proyecto `utebus-4435b` → **Authentication** → **Sign-in method** → habilitar correo/contraseña si el login falla por proveedor desactivado.

### Plataformas de desarrollo

- **Android** (dispositivo o emulador): objetivo principal del curso.
- **Web (Chrome)**: soportado para pruebas locales si `setup-local` generó opciones web; útil para S1-01 y depuración.
- Ejecutar siempre `setup-local` y `flutter run` desde las rutas documentadas en [README.md](../README.md) (raíz del repo, no desde `apps/firebase/tools`).

## Siguiente oleada de issues

| Prioridad | Módulo | Qué falta |
|-----------|--------|-----------|
| 1 | `profile` | Perfil, avisos de notificaciones, eliminar cuenta (derechos ARCO) |
| 2 | `routes_map` | Google Maps, paradas, ubicación; ya está la lista y el permiso al crear |
| 3 | `reservations` | Reservas con transacción de cupo |
| 4 | Backend | `apps/firebase/functions/` para QR, pagos y notificaciones |
| 5 | Administración | `admin-web/` con verificación de cuentas |

## Features en `apps/mobile/lib/src/features/`

| Feature | Estado | Notas |
|---------|--------|-------|
| auth | activo | Login, registro, verificación, sesión |
| home | activo | Saludo, cierre de sesión, barra inferior hacia `/rutas` |
| routes_map | activo (parcial) | Lista `rutas`; mapa pendiente |
| profile | stub | Siguiente después de auth estable |
| reservations, boarding, trip, incidents, operator, admin | stub | Copiar las capas de `auth` |

## Comprobación rápida

```powershell
.\scripts\check.ps1
.\scripts\verify-activity.ps1 -Tipo feature -Feature auth
```