# Flujos de Usuario — transporte-estudiantil-utez

Esta carpeta documenta los **flujos de navegación y de negocio** de la app Flutter: recorridos del usuario entre pantallas, decisiones del router, guards y redirecciones según el estado de sesión y el rol.

Código canónico: `lib/src/core/router/app_router.dart` (GoRouter con redirección por `AuthSessionState`).

---

## Índice

| Flujo | Ámbito | Documento |
|-------|--------|-----------|
| Autenticación | Login → Registro → Verificación → Inicio | [auth/flujo-autenticacion.md](./auth/flujo-autenticacion.md) |
| Estudiante | Inicio → Rutas → Reservas → Abordaje → Viaje → Incidencias | [estudiante/flujo-estudiante.md](./estudiante/flujo-estudiante.md) |
| Operador | Inicio → Salidas → Lista de abordaje → Validar QR | [operador/flujo-operador.md](./operador/flujo-operador.md) |

---

## Roles y home por defecto

| Rol | Home tras login | Rutas principales |
|-----|-----------------|-------------------|
| Estudiante | `/inicio` | `/inicio`, `/rutas`, `/reservas`, `/abordaje`, `/viaje`, `/incidencias`, `/perfil` |
| Operador | `/operador` | `/operador` (salidas, lista de abordaje, QR) |
| Administrador | — (panel web pendiente) | `admin-web/` (pendiente) |

La redirección por rol y estado de sesión se resuelve en `app_router.dart` con `AuthSessionCubit` y `StreamListenable`.

---

## Guards y redirecciones

| Situación | Comportamiento |
|-----------|----------------|
| Sin sesión | Solo se permiten `/login` y `/registro` |
| Sesión pendiente o rechazada | Redirige a `/verificacion` |
| Sesión aprobada (estudiante) | Redirige a `/inicio`; no puede volver a pantallas de auth |
| Sesión aprobada (operador) | Redirige a `/operador` |
| Sesión aprobada (rol desconocido) | Se trata como perfil inválido; no asume rol por defecto |

---

## Diferencia con `docs/pantallas/`

Aquí se documenta el **recorrido** entre pantallas; en `pantallas/` se documenta cada pantalla por separado.

---

## Cómo documentar un flujo nuevo

1. Crear `docs/flujos/[rol]/flujo-*.md`.
2. Incluir diagrama textual de navegación entre pantallas.
3. Documentar guards y redirecciones aplicables.
4. Indicar el home por defecto según el rol.
5. Registrar el flujo en este índice.

---

## Documentación relacionada

- [../pantallas/](../pantallas/README.md) — Documentación por pantalla.
- [../arquitectura.md](../arquitectura.md) — Router, redirecciones, `AuthSessionCubit`.
- [../modulos/](../modulos/README.md) — Índice de módulos por rol.
- [../estado.md](../estado.md) — Hecho frente a pendiente por feature.
