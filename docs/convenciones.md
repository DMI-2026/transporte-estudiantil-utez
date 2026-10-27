# Convenciones del repositorio

Cómo escribimos, probamos y organizamos el código. Este archivo cubre Git y el sensor de verificación; las capas Flutter están en [reglas-desarrollo.md](reglas-desarrollo.md).

Código canónico: `lib/` en la raíz del repositorio.

## Correspondencia con la plantilla del curso

El curso de Desarrollo Móvil Integral propone seis documentos numerados (alcance, PRD, integraciones, arquitectura, datos, convenciones). Aquí no se duplican: su contenido ya está en estos archivos.

| Documento de la plantilla | Dónde está aquí |
|---------------------------|-----------------|
| 01 Alcance | [README.md](README.md), sección Propósito, y [referencia-dmi.md](referencia-dmi.md) |
| 02 PRD | [modulos/](modulos/) y [estado.md](estado.md) |
| 03 Integraciones | [servicios.md](servicios.md) |
| 04 Arquitectura | [arquitectura.md](arquitectura.md) |
| 05 Datos | [arquitectura-y-datos/](arquitectura-y-datos/) |
| 06 Convenciones | este archivo |

Protocolo para agentes de IA: [README.md](README.md).

## Tabla de decisiones

Cada convención tiene un código (C-01 a C-12) para citarla en PRs y en el código. El código siempre se acompaña de su significado cuando se usa fuera de esta tabla.

| Código | Decisión | Alternativa descartada | Por qué | Fecha |
|--------|----------|------------------------|---------|-------|
| C-01 | Una rama por issue: `feat/<n>-<tema>` o `fix/<n>-<tema>` desde `develop` | Trabajar todos sobre `main` o `develop` | Cada cambio se revisa por separado | 2026-10-26 |
| C-02 | Conventional Commits en español (`feat`, `fix`, `docs`, `test`, `chore`) | Mensajes libres | Historial legible en la defensa | 2026-10-26 |
| C-03 | `develop` y `main` solo reciben PRs aprobados por otra persona | Aprobar el propio PR | La revisión automática no sustituye a los pares | 2026-10-26 |
| C-04 | `.\scripts\check.ps1` es el único criterio de "listo"; el hook pre-commit lo ejecuta | Recordar `analyze` y `test` a mano | Mismo comando para personas, agentes y hook | 2026-10-26 |
| C-05 | Pruebas con `flutter test`; fakes en `test/fakes/` | Probar solo en emulador | Un commit con prueba rota se rechaza | 2026-10-26 |
| C-06 | La prueba nueva se escribe antes y falla; luego se hace pasar | Escribir la prueba al final | Una prueba que nunca falló no demuestra el error | 2026-10-26 |
| C-07 | Backend = Firebase (Auth, Firestore, Storage) + Cloud Functions; sin API Node propia | API REST propia | Decisión del issue #46; un solo backend en la nube | 2026-10-26 |
| C-08 | Features con capas domain, data y presentation; todo el estado de UI con `flutter_bloc` (Cubit), incluida la sesión | MVVM con `ChangeNotifier` | Un solo gestor de estado en toda la app | 2026-10-26 |
| C-09 | Padrón y control de cambios en `CONTRIBUIDORES.md` | Directrices solo en AGENTS.md | Misma organización que el curso | 2026-10-26 |
| C-10 | Acceso a Auth y Firestore solo en `data/` (gateway y datasource); fallos sellados en `AppFailure` | SDK de Firebase en widgets | La UI muestra mensajes de usuario, nunca errores técnicos | 2026-10-26 |
| C-11 | Tema en `lib/src/core/theme/` (`AppColors`, `AppSpacing`, `AppRadii`); pantallas remotas con `UiState` + `MensajeEstado` | Colores hex sueltos o SnackBar como único error | Disciplina visual con la paleta UTEZ | 2026-10-26 |
| C-12 | Se mantiene `google_fonts` (Source Sans 3) | Quitar paquetes de fuentes | Ya está en `pubspec`; no se quita sin un issue | 2026-10-26 |

`verify-activity.ps1` es un extra al cerrar un issue (secretos, Firebase, carpeta de feature). No reemplaza a C-04.

## Qué no se iguala con el proyecto de cafetería (a propósito)

| Cafetería | Transporte |
|-----------|------------|
| `apps/api/` con Node y Express | No. Firebase y Cloud Functions (C-07) |
| `ChangeNotifier` y carpetas `views/` | No. Bloc/Cubit y `features/*/presentation` (C-08) |
| Tema sin `google_fonts` | No. Se conserva (C-12) |
| Monorepo con `apps/mobile` | App en la raíz del repositorio (`lib/`) |

## Organización

```text
lib/src/core/          theme, errors, widgets, router, di, firebase
lib/src/features/<n>/  domain | data | presentation
test/                  espejo de lib/ más fakes/
firebase/              reglas e índices (no hay API Node)
scripts/check.ps1      sensor único (C-04)
.githooks/             el pre-commit corre el sensor
```

## Al clonar (una sola vez)

```powershell
git config core.hooksPath .githooks
flutter pub get
.\scripts\setup-local.ps1
.\scripts\check.ps1
```
