# Transporte exclusivo estudiantil UTEZ

App para que estudiantes y operadores reserven asiento, sigan la combi y aborden con QR. El administrador verifica cuentas y catálogo desde un panel web (pendiente).

Proyecto del curso Desarrollo Móvil Integral (UTEZ). App Flutter con backend Firebase (proyecto `utebus-4435b`). Código canónico: `lib/`.

## Qué hay aquí

| Carpeta o archivo | Qué es |
|-------------------|--------|
| `lib/` | App Flutter (estudiante y operador) |
| `firebase/` | Reglas e índices de Firestore y Storage |
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
| Alison | `firebase/`, Cloud Functions |
| Jesús | `functions/`, `admin-web` |

Detalle: [CONTRIBUIDORES.md](CONTRIBUIDORES.md).

## Cómo correrlo

Requisitos: Git y Flutter estable (Dart 3). No hay API Node: el backend es Firebase (convención C-07).

```powershell
git clone <url> transporte-estudiantil-utez
cd transporte-estudiantil-utez
git checkout develop
git config core.hooksPath .githooks
flutter pub get
.\scripts\setup-local.ps1
.\scripts\check.ps1
flutter run --dart-define-from-file=env/dev.json
```

`env/dev.json` y `lib/firebase_options.dart` no se versionan. Guía de configuración local: [docs/estado.md](docs/estado.md).

## Verificar todo

El único comando de "listo" es el sensor `check.ps1` (analyze + test). El hook pre-commit lo ejecuta; no uses `--no-verify`.

| Qué | Comando |
|-----|---------|
| Verificar todo | `.\scripts\check.ps1` |
| Correr la app | `flutter run --dart-define-from-file=env/dev.json` |
| Extra al cerrar un issue (secretos, Firebase) | `.\scripts\verify-activity.ps1 -Tipo base` |

`verify-activity.ps1` no sustituye a `check.ps1`.
