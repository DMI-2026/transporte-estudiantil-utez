# Documentación de Pantallas — transporte-estudiantil-utez

Esta carpeta documenta cada **pantalla** de la app Flutter: propósito, ruta, acceso, estado de implementación, archivos involucrados y guía de construcción.

Código canónico: `lib/src/features/<feature>/presentation/` (widgets + Cubit), `lib/src/features/<feature>/domain/` (contratos) y `lib/src/features/<feature>/data/` (datasources + repositorio).

---

## Índice

### Autenticación (`/login`, `/registro`, `/verificacion`)

| Pantalla | Ruta | Rol | Estado | Documento |
|----------|------|-----|--------|-----------|
| Inicio de sesión | `/login` | Estudiante / Operador | Activo | [auth/login.md](./auth/login.md) |
| Registro | `/registro` | Estudiante / Operador | Activo | [auth/registro.md](./auth/registro.md) |
| Verificación | `/verificacion` | Estudiante / Operador | Activo | [auth/verificacion.md](./auth/verificacion.md) |

### Estudiante

| Pantalla | Ruta | Rol | Estado | Documento |
|----------|------|-----|--------|-----------|
| Inicio | `/inicio` | Estudiante | Activo | [home.md](./home.md) |
| Perfil | `/perfil` | Estudiante | Stub | [profile.md](./profile.md) |
| Rutas y mapa | `/rutas` | Estudiante | Stub | [routes_map.md](./routes_map.md) |
| Reservas | `/reservas` | Estudiante | Stub | [reservations.md](./reservations.md) |
| Abordaje con QR | `/abordaje` | Estudiante | Stub | [boarding.md](./boarding.md) |
| Seguimiento del viaje | `/viaje` | Estudiante | Stub | [trip.md](./trip.md) |
| Incidencias | `/incidencias` | Estudiante | Stub | [incidents.md](./incidents.md) |

### Operador

| Pantalla | Ruta | Rol | Estado | Documento |
|----------|------|-----|--------|-----------|
| Panel operador | `/operador` | Operador | Stub | [operator.md](./operator.md) |

### Administración

| Pantalla | Ruta | Rol | Estado | Documento |
|----------|------|-----|--------|-----------|
| Panel web admin | — | Administrador | Pendiente | [admin.md](./admin.md) |

---

## Plantilla recomendada por pantalla

Cada documento de pantalla sigue esta estructura:

1. **Propósito** — qué resuelve la pantalla para el usuario.
2. **Ruta y acceso** — URL de GoRouter, guard, quién puede entrar y layout.
3. **Estado de implementación** — activo / stub / pendiente.
4. **Diseño y secciones** — composición visual del widget.
5. **Archivos involucrados** — árbol de `lib/src/features/<feature>/`.
6. **Datos y contratos** — colecciones de Firestore, modelos, validadores.
7. **Guía de construcción** — pasos para implementar o completar la pantalla.
8. **Credenciales y datos de prueba** — si aplica.

---

## Cómo agregar una pantalla nueva

1. Crear la feature en `lib/src/features/<nombre>/` con capas `domain/`, `data/` y `presentation/`.
2. Registrar la ruta en `lib/src/core/router/app_routes.dart` con el guard correspondiente.
3. Implementar el Cubit con estado `Equatable` y usar `UiState` + `UiStateView` + `MensajeEstado`.
4. Registrar las dependencias en `lib/src/core/di/injection.dart`.
5. Escribir pruebas en `test/` espejo de `lib/`, usando fakes de `test/fakes/`.
6. Documentar la pantalla en `docs/pantallas/[rol]/<feature>.md` usando la plantilla de arriba.
7. Si la pantalla introduce un flujo nuevo, documentarlo en `docs/flujos/`.
8. Ejecutar `.\scripts\check.ps1` (criterio único de "listo", convención C-04).

---

## Estados de implementación

| Estado | Significado |
|--------|-------------|
| Activo | Implementado y verificado con `.\scripts\check.ps1` |
| Stub | Carpeta de feature creada, sin código de negocio |
| Pendiente | Acordado o planificado, todavía no está en código |

---

## Documentación relacionada

- [../arquitectura.md](../arquitectura.md) — Capas, árbol de `lib/`, router, Firestore.
- [../reglas-desarrollo.md](../reglas-desarrollo.md) — Capas Flutter, nombres de Firestore, seguridad.
- [../flujos/](../flujos/README.md) — Flujos de navegación entre pantallas.
- [../modulos/](../modulos/README.md) — Índice de módulos por rol y funcionalidad.
