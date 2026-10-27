# Bitácora de uso de IA

Registro que pide el curso sobre el uso de herramientas de IA. Sin secretos ni datos personales. Se usa solo para decisiones técnicas importantes (motivo y consecuencia), no como registro de commits. Cuándo escribir: [README, sección Cuándo actualizar documentación](../README.md#cuándo-actualizar-documentación).

| Fecha | Integrante | Herramienta | Objetivo | Resultado |
|-------|------------|-------------|----------|-----------|
| 2026-10-26 | Equipo 1 | Cursor | Reestructurar docs para IA mínima | 5 archivos core en `docs/` |
| 2026-10-26 | Equipo 1 | Cursor | Protocolo 10 pasos, `modulos/`, referencia DMI, reglas Cursor unificadas | Ver `docs/README.md`, `AGENTS.md` |
| 2026-10-26 | Equipo 1 | Cursor | Backend Firebase utebus-4435b: reglas Firestore/Storage, índices, seed demo | Modelo en `docs/arquitectura-y-datos/`; checklist en `docs/estado.md` |
| 2026-10-26 | Equipo 1 | Cursor | Criterios de arranque: autenticación, estados de pantalla (`UiState`), Bloc, router | Patrón en `features/auth/`; setup `scripts/setup-local.ps1` |
| 2026-10-26 | Equipo 1 | Cursor | Igualar disciplina DMI con cafetería (pasos 0–4, sin quitar clone) | Sensor `check.ps1`, hook, `CONTRIBUIDORES.md`, `AppFailure`, `MensajeEstado`, tests/fakes auth |
| 2026-10-26 | Equipo 1 | Cursor | Fases 5–6 docs: mapa DMI, README corto, qué no se iguala | `convenciones.md` C-07/C-08/C-12; README raíz Cómo correrlo + Verificar todo |
| 2026-10-26 | Equipo 1 | Cursor | Quitar clone `cafeteria_utez/` del repo de transporte | Carpeta eliminada; analyzer ya no la excluye |
| 2026-10-26 | Equipo 1 | Cursor | Auditoría: regla QR (`/privado/{docId}`), `signUp` sin perfil = fallo + cierre de sesión huérfana, rol desconocido = perfil inválido, seed prod exige service account, sin client secret en repo | Reglas redesplegadas; `verify-activity` escanea `.mjs/.js/.ps1`; tests sesión + redirects |
| 2026-10-27 | Equipo 1 | Cursor | Sesión global como `AuthSessionCubit` (un solo gestor de estado, C-08); `LoginPage` sin dependencia de `FirebaseBootstrap` (`AuthRepository.isAvailable`); cierre de sesión vía Cubit, no desde widgets a `get_it` | `StreamListenable` para `refreshListenable`; 40 pruebas. Documentación reescrita sin símbolos ni códigos del enunciado |
| 2026-10-27 | Equipo 1 | Cursor | Pendientes de la auditoría: pruebas de reglas contra emulador, `integration_test` del arranque, Storage `documentacion/` partido en público vs por uid | Storage ya no deja leer documentos de otro usuario; reglas se prueban con `npm run test:emulator` |

Cada integrante debe poder explicar su parte en defensa.
