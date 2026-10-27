# Pantalla: Inicio de sesión (`/login`)

Permite que un usuario existente acceda a su área según su rol (estudiante o operador).

---

## Ruta y acceso

| Atributo | Valor |
|----------|-------|
| Ruta | `/login` |
| Rol | Estudiante y operador |
| Acceso | Solo sin sesión (redirige a `/inicio` si ya hay sesión aprobada) |
| Layout | Pantalla de autenticación (sin sidebar) |
| Registro de ruta | `lib/src/core/router/app_routes.dart` |

Si ya hay sesión activa y aprobada, el router redirige al home correspondiente.

---

## Estado de implementación

**Activo** — Implementado con Firebase Auth, `AuthRepositoryImpl`, `AuthSessionCubit` y pruebas en `test/`.

---

## Diseño y secciones

- Formulario con campos: correo electrónico y contraseña.
- Botón de "Iniciar sesión".
- Enlace a "¿No tienes cuenta? Regístrate" → `/registro`.
- Mensajes de error genéricos para el usuario (sin detalles técnicos).
- Estados de carga y error mediante `UiState` + `UiStateView` + `MensajeEstado`.

---

## Archivos involucrados

```text
lib/src/features/auth/
├── domain/
│   ├── AuthRepository.dart           # Contrato del repositorio
│   └── AppUser.dart                  # Entidad de usuario
├── data/
│   ├── FirebaseAuthGateway.dart      # Datasource de Firebase Auth
│   ├── FirestoreUserRemoteDataSource.dart  # Datasource de Firestore (usuarios)
│   └── AuthRepositoryImpl.dart       # Implementación del repositorio
├── presentation/
│   ├── login_cubit.dart              # Cubit de login
│   ├── login_state.dart              # Estado del Cubit (Equatable)
│   └── login_page.dart               # Widget de la pantalla
test/
└── features/auth/
    └── login_cubit_test.dart         # Pruebas del Cubit
```

Dependencias registradas en `lib/src/core/di/injection.dart`.

---

## Datos y contratos

| Colección | Documento | Campos relevantes |
|-----------|-----------|-------------------|
| `usuarios` | `{uid}` | `rol`, `estadoVerificacion`, `creadoEn` |

- `rol`: `estudiante` o `operador`.
- `estadoVerificacion`: `pendiente`, `aprobada`, `rechazada`.
- Un rol o estado de verificación desconocido se trata como perfil inválido.

---

## Guía de construcción

1. El usuario envía correo y contraseña.
2. `LoginCubit` llama al `AuthRepository`.
3. `AuthRepositoryImpl` usa `FirebaseAuthGateway` para autenticar.
4. Tras el login, se lee el documento `usuarios/{uid}` en Firestore.
5. Si el perfil es válido y aprobado, `AuthSessionCubit` emite la sesión y el router redirige a `/inicio`.
6. Si el estado es `pendiente` o `rechazada`, se redirige a `/verificacion`.

---

## Credenciales de prueba

| Rol | Correo | Contraseña | Nota |
|-----|--------|------------|------|
| Estudiante | `alumno@utez.edu.mx` | (según datos demo) | Dominio `@utez.edu.mx` |
| Operador | `operador@ejemplo.com` | (según datos demo) | Correo libre |

Los datos demo se cargan con `scripts/seed-firestore-prod.ps1` o `scripts/seed-firestore.ps1`.

---

## Documentación relacionada

- [../estado.md](../estado.md) — Hecho frente a pendiente.
- [../arquitectura.md](../arquitectura.md) — Router y redirección por sesión.
- [../reglas-desarrollo.md](../reglas-desarrollo.md) — Seguridad y mensajes de error.
- [../flujos/auth/flujo-autenticacion.md](../flujos/auth/flujo-autenticacion.md) — Flujo completo de autenticación.
