# Flujo de Autenticación

Recorrido del usuario desde la landing de auth hasta el área correspondiente según su rol.

---

## Diagrama de navegación

```
                    ┌─────────────┐
                    │   Login     │  /login
                    └──────┬──────┘
             ┌─────────────┴─────────────┐
             ▼                           ▼
    ┌─────────────────┐         ┌─────────────────┐
    │  Credenciales   │         │  ¿No tienes     │
    │  correctas?     │         │  cuenta?        │
    └────────┬────────┘         │  Regístrate     │
             ▼                  └────────┬────────┘
    ┌─────────────────┐                 ▼
    │  Firebase Auth  │          ┌─────────────┐
    │  + Firestore    │          │   Registro  │  /registro
    └────────┬────────┘          └────────┬────────┘
             ▼                           ▼
    ┌─────────────────┐          ┌─────────────────┐
    │  Leer usuarios/ │          │  Crear cuenta   │
    │  {uid}          │          │  en estado      │
    └────────┬────────┘          │  pendiente      │
             ▼                   └────────┬────────┘
    ┌─────────────────────────────────────┴─────────────────┐
    ▼                                                       ▼
pendiente/rechazada                                    aprobada
    ▼                                                       ▼
┌─────────┐                                         ┌───────────┐
│Verificación│                                      │   /inicio   │
│  /verificacion│                                    │ (estudiante)│
└─────────┘                                         └───────────┘
      │                                                       │
      ▼ (aprobada)                                            ▼
┌─────────┐                                         ┌───────────┐
│  /inicio  │                                       │  /operador  │
│ (estudiante)│                                     │ (operador)  │
└─────────┘                                         └───────────┘
```

---

## Pantallas involucradas

| Pantalla | Ruta | Rol | Guard |
|----------|------|-----|-------|
| Inicio de sesión | `/login` | Estudiante / Operador | Solo sin sesión |
| Registro | `/registro` | Estudiante / Operador | Solo sin sesión |
| Verificación | `/verificacion` | Estudiante / Operador | Cuenta pendiente / rechazada |
| Inicio | `/inicio` | Estudiante | Sesión aprobada |
| Panel operador | `/operador` | Operador | Sesión aprobada + rol operador |

---

## Guards y redirecciones

| Prop / Condición | Uso |
|------------------|-----|
| Sesión nula | Solo `/login` y `/registro` permitidos |
| `estadoVerificacion` = `pendiente` o `rechazada` | Redirige a `/verificacion` |
| `estadoVerificacion` = `aprobada` + rol `estudiante` | Redirige a `/inicio` |
| `estadoVerificacion` = `aprobada` + rol `operador` | Redirige a `/operador` |
| Rol o estado desconocido | Perfil inválido; no asume rol por defecto |

---

## Archivos clave

- `lib/src/core/router/app_routes.dart` — Rutas y redirección por `AuthSessionState`.
- `lib/src/core/router/app_router.dart` — `GoRouter` con `refreshListenable` (StreamListenable).
- `lib/src/core/router/stream_listenable.dart` — Adapta el stream del Cubit a GoRouter.
- `lib/src/features/auth/presentation/auth_session_cubit.dart` — Sesión global y estado de verificación.
- `lib/src/core/di/injection.dart` — Inyección de `AuthSessionCubit` y repositorios.

---

## Flujo paso a paso

1. Usuario abre la app sin sesión → ve `/login`.
2. Usuario inicia sesión con credenciales válidas → `AuthRepository` autentica con Firebase Auth y lee `usuarios/{uid}`.
3. Si el estado es `pendiente` o `rechazada` → router redirige a `/verificacion`.
4. Si el estado es `aprobada`:
   - Rol `estudiante` → redirige a `/inicio`.
   - Rol `operador` → redirige a `/operador`.
5. Usuario se registra → cuenta se crea en `pendiente`; se invita a iniciar sesión tras la aprobación del administrador.
6. Administrador aprueba en el panel web → `estadoVerificacion` pasa a `aprobada`; la sesión se actualiza y el router redirige al home del rol.

---

## Documentación relacionada

- [../pantallas/auth/login.md](../pantallas/auth/login.md)
- [../pantallas/auth/registro.md](../pantallas/auth/registro.md)
- [../pantallas/auth/verificacion.md](../pantallas/auth/verificacion.md)
- [../pantallas/home.md](../pantallas/home.md)
- [../pantallas/operator.md](../pantallas/operator.md)
- [../arquitectura.md](../arquitectura.md) — Router y redirecciones.
- [../reglas-desarrollo.md](../reglas-desarrollo.md) — Sesión global y redirección.
