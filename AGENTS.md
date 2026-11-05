# AGENTS.md · Transporte estudiantil UTEZ

Mapa: `apps/mobile/` app Flutter (estudiante y operador) · `apps/firebase/` reglas, pruebas de reglas y Cloud Functions · `docs/` decisiones (01 a 06).

- Verifica con `./scripts/check.sh` (en Windows `.\scripts\check.ps1`) antes de cada commit; el hook pre-commit lo ejecuta (C-04).
- Lee `docs/01-alcance.md` y `docs/06-convenciones.md` antes de proponer; una decisión nueva va a la tabla del documento donde nace.
- Abre un issue antes de la rama; usa una rama por issue `feat/<n>-<tema>` desde `develop` y nunca hagas push a `main` ni a `develop` (C-01).
- Cierra el issue en el PR con `Closes #<n>` y pide la aprobación de otra persona del equipo (C-03).
- Escribe primero la prueba y comprueba que falla; un bug corregido llega con su prueba (C-06).
- Prueba con `flutter test` y los fakes de `apps/mobile/test/fakes/`; no agregues otro framework de pruebas ni levantes Firebase en una prueba (C-05).
- Usa Firebase y Cloud Functions como único backend; no crees una API propia (D-03, C-07).
- Usa el SDK de Firebase solo en `data/` y maneja el estado de UI con Cubits de `flutter_bloc` (C-08, C-10).
- Aprueba pagos y valida el QR solo en Cloud Functions, nunca en la app (D-05, D-06).
- Nunca: secretos en el repo (llaves de Mercado Pago o Routes, service accounts, `env/dev.json`), `--no-verify`, ni borrar o debilitar pruebas para que pasen.
