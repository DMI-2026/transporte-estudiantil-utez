# Guía para Claude

Este archivo es el punto de entrada para Claude. Cursor usa el mismo flujo desde [AGENTS.md](AGENTS.md). La arquitectura no se describe aquí: vive en `docs/` y no debe duplicarse.

## Qué es este proyecto

App Flutter de transporte estudiantil para la UTEZ (roles estudiante y operador) con backend en Firebase (proyecto `utebus-4435b`). El panel de administración será una web aparte, aún pendiente. Todo el código Flutter canónico está en `lib/`.

## Cómo empezar una tarea

Normalmente la tarea llega como un issue de GitHub pegado en el chat. Sigue este orden:

1. Lee [docs/README.md](docs/README.md), sección **Protocolo de tarea** (diez pasos). Es obligatorio.
2. Lee [docs/reglas-desarrollo.md](docs/reglas-desarrollo.md) para capas Flutter, nombres de Firestore y seguridad.
3. Abre solo la documentación que el issue necesite:
   - [docs/modulos/README.md](docs/modulos/README.md) para ubicar el módulo por rol o funcionalidad.
   - [docs/servicios.md](docs/servicios.md) si el issue toca Firebase, paquetes o APIs externas.
   - [docs/arquitectura.md](docs/arquitectura.md) si cambia la estructura de carpetas o el modelo de datos.
   - [docs/referencia-dmi.md](docs/referencia-dmi.md) si el issue cita historias de usuario o requisitos del enunciado.

## Reparto de responsabilidades

Alison mantiene `firebase/` (reglas e índices). Jesús trabaja en `functions/` y `admin-web/`. Si tu issue es de backend, no toques `lib/` salvo que el issue lo pida de forma explícita.

## Reglas que no se negocian

- El único criterio de "listo" es `.\scripts\check.ps1` (analyze + test). El hook pre-commit lo ejecuta. Nunca uses `--no-verify`.
- Diff mínimo: implementa solo lo que pide el issue. No refactorices ni agregues dependencias que nadie pidió.
- No reviertas trabajo del usuario ni borres archivos fuera del alcance.
- Nunca commitees `google-services.json`, `GoogleService-Info.plist`, `lib/firebase_options.dart`, `env/dev.json` ni claves de Mercado Pago o Google Routes.
- El cliente Flutter nunca marca un pago como aprobado ni escribe el secreto del QR; eso es trabajo de Cloud Functions.

## Cómo cerrar una tarea

- Ejecuta `.\scripts\check.ps1` y, si el issue lo pide, `.\scripts\verify-activity.ps1`. No afirmes que corriste pruebas que no corriste.
- Entrega el reporte con el formato de [docs/README.md, sección Reporte final](docs/README.md#reporte-final).
