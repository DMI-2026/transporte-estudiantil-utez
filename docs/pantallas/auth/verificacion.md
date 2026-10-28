# Pantalla: Verificación de cuenta (`/verificacion`)

Muestra el estado de verificación de la cuenta tras el registro. La cuenta queda en estado `pendiente` hasta que un administrador la apruebe o rechace.

---

## Ruta y acceso

| Atributo | Valor |
|----------|-------|
| Ruta | `/verificacion` |
| Rol | Estudiante y operador |
| Acceso | Cuenta pendiente o rechazada |
| Layout | Pantalla de autenticación (sin sidebar) |
| Registro de ruta | `lib/src/core/router/app_routes.dart` |

Las cuentas aprobadas no pueden acceder a esta pantalla; redirigen a `/inicio`.

---

## Estado de implementación

**Activo** — Implementado con `AuthSessionCubit` y redirección por estado de sesión.

---

## Diseño y secciones

- Mensaje informativo: "Tu cuenta está pendiente de aprobación".
- Indicador de estado: pendiente / rechazada.
- Si rechazada: motivo (si está disponible) y opción de volver a registrar.
- Botón de "Reintentar" o "Volver al login".

---

## Archivos involucrados

```text
lib/src/features/auth/
├── domain/
│   ├── AuthRepository.dart
│   └── AppUser.dart
├── data/
│   ├── FirebaseAuthGateway.dart
│   ├── FirestoreUserRemoteDataSource.dart
│   └── AuthRepositoryImpl.dart
├── presentation/
│   ├── auth_session_cubit.dart      # Sesión global y estado de verificación
│   └── verificacion_page.dart
```

---

## Datos y contratos

| Colección | Documento | Campos relevantes |
|-----------|-----------|-------------------|
| `usuarios` | `{uid}` | `estadoVerificacion` (`pendiente`, `aprobada`, `rechazada`) |

---

## Guía de construcción

1. El router observa `AuthSessionCubit` a través de `StreamListenable`.
2. Si el estado de verificación es `pendiente` o `rechazada`, se muestra `/verificacion`.
3. Si cambia a `aprobada`, se redirige automáticamente a `/inicio`.
4. Un estado desconocido se trata como perfil inválido.

---

## Credenciales de prueba

Ver [auth/login.md](./login.md).

---

## Documentación relacionada

- [../estado.md](../estado.md) — Router: `/login`, `/registro`, `/verificacion`, `/inicio`.
- [../arquitectura.md](../arquitectura.md) — Redirecciones por `AuthSessionState`.
- [../flujos/auth/flujo-autenticacion.md](../flujos/auth/flujo-autenticacion.md) — Flujo completo de autenticación.
