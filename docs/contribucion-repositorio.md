# Contribución y versionado

Convenciones de ramas y commits: [06-convenciones.md](06-convenciones.md) (C-01 a C-03). Este documento resume **qué entra en Git** y **qué deja cada persona en su máquina** para que el equipo corra el proyecto completo.

## Ramas

| Rama | Uso |
|------|-----|
| `main` | Producción; solo merges desde PR aprobados |
| `develop` | Integración del equipo; base para nuevas ramas |
| `feat/<n>-<tema>` o `fix/<n>-<tema>` | Una rama por issue, creada desde `develop` |

No hacer push directo a `main` ni a `develop`.

## Qué **sí** se versiona

| Área | Contenido típico |
|------|------------------|
| `apps/mobile/lib/` | Código Flutter (features, core, router, DI) |
| `apps/mobile/test/` y `integration_test/` | Pruebas unitarias e integración |
| `apps/mobile/pubspec.yaml` / `pubspec.lock` | Dependencias |
| `apps/mobile/env/example.json` | Plantilla de `USE_FIREBASE` |
| `apps/mobile/lib/firebase_options.example.dart` | Plantilla sin secretos |
| `apps/firebase/` | `firebase.json`, `.firebaserc`, reglas, índices, `tools/seed-demo-data.mjs` |
| `scripts/` | `check.ps1`, `setup-local.ps1`, `seed-firestore.ps1`, etc. |
| `docs/` | Documentación del equipo |
| `.githooks/` | Pre-commit con `check.ps1` |

## Qué **no** se versiona (`.gitignore`)

| Archivo o carpeta | Motivo |
|-------------------|--------|
| `apps/mobile/env/dev.json` | Define si Firebase está activo en local |
| `apps/mobile/lib/firebase_options.dart` | Generado por FlutterFire |
| `**/google-services.json`, `**/GoogleService-Info.plist` | Config nativa Firebase |
| `apps/firebase/env/` | Service account para seed local |
| `*-adminsdk-*.json`, `.env`, claves Mercado Pago / Maps | Secretos |
| `node_modules/`, `build/`, `.dart_tool/` | Artefactos |

Tras clonar, cada integrante ejecuta `.\scripts\setup-local.ps1 -RunFlutterfire` y, si necesita cuentas demo, el seed con su service account.

## Qué **no** conviene incluir en un PR

- Instrumentación temporal de depuración (logs a servidores externos).
- Entregables del curso en binario (`*.docx`) salvo acuerdo del equipo.
- Cambios masivos ajenos al issue (reglas Firebase, Gradle, etc.) sin coordinación con quien mantiene `apps/firebase/`.

## Lista de verificación antes de abrir PR

1. `git config core.hooksPath .githooks`
2. `.\scripts\check.ps1` en verde
3. Sin archivos ignorados en el staging (`git status` limpio de secretos)
4. Título del PR y `Closes #<n>` según el issue
5. Revisión de otra persona (C-03)

## Referencias

- Arranque local: [README.md](../README.md) y [estado.md](estado.md)
- Login y cuentas demo: [pantallas/auth/login.md](pantallas/auth/login.md)
- Backend Firebase: [../apps/firebase/README.md](../apps/firebase/README.md)