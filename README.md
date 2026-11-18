# Transporte exclusivo estudiantil UTEZ

App para que estudiantes y operadores reserven asiento, sigan la combi y aborden con QR. El administrador verifica cuentas y catálogo desde un panel web (pendiente).

Proyecto del curso Desarrollo Móvil Integral (UTEZ). App Flutter con backend Firebase (proyecto `utebus-4435b`). Código canónico: `apps/mobile/lib/`.

## Qué hay aquí

| Carpeta o archivo | Qué es |
|-------------------|--------|
| `apps/mobile/lib/` | App Flutter (estudiante y operador) |
| `apps/firebase/` | Reglas e índices de Firestore y Storage |
| `docs/` | Documentación del equipo: módulos, servicios, datos, convenciones |
| `CONTRIBUIDORES.md` | Integrantes y control de cambios |
| `AGENTS.md` y `CLAUDE.md` | Guía para agentes de IA |
| `scripts/check.ps1` y `.githooks/` | Sensor único de verificación (convención C-04) |

Índice completo y protocolo para IA: [docs/README.md](docs/README.md). Qué está hecho y qué falta: [docs/estado.md](docs/estado.md).

## Roles

| Persona | Enfoque |
|---------|---------|
| Juan | `routes_map` |
| Hanna | `auth`, `profile` |
| David | `home`, `trip` |
| Coordinación | PR, `reservations` |
| Alison | `apps/firebase/`, Cloud Functions |
| Jesús | `apps/firebase/functions/`, `admin-web` |

Detalle: [CONTRIBUIDORES.md](CONTRIBUIDORES.md).

## Cómo correrlo

Requisitos: Git, Flutter estable (Dart 3), Node y Firebase CLI (`npm install -g firebase-tools`). No hay API Node de la app: el backend es Firebase (convención C-07). Objetivo principal: **Android** (dispositivo o emulador). También puedes probar en **Chrome** (web) si FlutterFire generó las opciones web.

Una sola vez, desde la raíz:

```powershell
git clone <url> transporte-estudiantil-utez
cd transporte-estudiantil-utez
git checkout develop
git config core.hooksPath .githooks
firebase login
.\scripts\setup-local.ps1 -RunFlutterfire
.\scripts\check.ps1
cd apps/mobile
flutter devices
flutter run --dart-define-from-file=env/dev.json
```

`flutter devices` tiene que listar un dispositivo Android antes de `flutter run`. Si no hay ninguno: `flutter emulators` y `flutter emulators --launch <nombre>`.

`setup-local.ps1 -RunFlutterfire` escribe los archivos locales (no se versionan) y deja `USE_FIREBASE` en `true` solo cuando los tres existen:

| Archivo | Para qué |
|---------|----------|
| `apps/mobile/env/dev.json` | `USE_FIREBASE` |
| `apps/mobile/lib/firebase_options.dart` | Opciones de `Firebase.initializeApp` |
| `apps/mobile/android/app/google-services.json` | Firebase en Android |
| `apps/mobile/ios/Runner/GoogleService-Info.plist` | Firebase en iOS |

Quien no tenga acceso al proyecto `utebus-4435b` debe pedirlo en la consola antes de `firebase login`. En la consola, **Authentication → Sign-in method → Correo/Contraseña** debe estar habilitado; si no, el login responde `PASSWORD_LOGIN_DISABLED`. Para cuentas demo: `.\scripts\seed-firestore.ps1` (service account local, ver [docs/estado.md](docs/estado.md)). Qué subir a Git: [docs/contribucion-repositorio.md](docs/contribucion-repositorio.md).

## Verificar todo

El único comando de "listo" es el sensor `check.ps1` (analyze + test). El hook pre-commit lo ejecuta; no uses `--no-verify`.

| Qué | Comando |
|-----|---------|
| Verificar todo | `.\scripts\check.ps1` |
| Correr la app (desde `apps/mobile/`) | `flutter run --dart-define-from-file=env/dev.json` |
| Extra al cerrar un issue (secretos, Firebase) | `.\scripts\verify-activity.ps1 -Tipo base` |

`verify-activity.ps1` no sustituye a `check.ps1`.
