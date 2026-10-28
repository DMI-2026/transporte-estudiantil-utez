# Pantalla: Registro (`/registro`)

Permite crear una cuenta nueva de estudiante o operador. Tras el registro, la cuenta queda en estado `pendiente` hasta que un administrador la apruebe.

---

## Ruta y acceso

| Atributo | Valor |
|----------|-------|
| Ruta | `/registro` |
| Rol | Estudiante y operador |
| Acceso | Solo sin sesión |
| Layout | Pantalla de autenticación (sin sidebar) |
| Registro de ruta | `lib/src/core/router/app_routes.dart` |

---

## Estado de implementación

**Activo** — Implementado con Firebase Auth, Firestore y `RegistrationValidator`.

---

## Diseño y secciones

- Formulario con campos: nombre, apellidos, correo electrónico, contraseña, confirmar contraseña.
- Validación de dominio `@utez.edu.mx` para estudiantes (operador con correo libre).
- Checkbox de términos y condiciones.
- Botón de "Registrarse".
- Enlace a "¿Ya tienes cuenta? Inicia sesión" → `/login`.
- Pantalla de éxito tras el registro con indicación de verificación pendiente.

---

## Archivos involucrados

```text
lib/src/features/auth/
├── domain/
│   ├── AuthRepository.dart
│   ├── AppUser.dart
│   └── RegistrationValidator.dart
├── data/
│   ├── FirebaseAuthGateway.dart
│   ├── FirestoreUserRemoteDataSource.dart
│   └── AuthRepositoryImpl.dart
├── presentation/
│   ├── register_cubit.dart
│   ├── register_state.dart
│   └── register_page.dart
test/
└── features/auth/
    └── register_cubit_test.dart
```

---

## Datos y contratos

| Colección | Documento | Campos relevantes |
|-----------|-----------|-------------------|
| `usuarios` | `{uid}` | `rol`, `estadoVerificacion` = `pendiente`, `creadoEn` |

- El estudiante debe usar correo con dominio `@utez.edu.mx`.
- Si falla el guardado del perfil, la app cierra la sesión para no dejar una cuenta sin documento.

---

## Guía de construcción

1. El usuario completa el formulario de registro.
2. `RegistrationValidator` valida campos y dominio de correo.
3. `RegisterCubit` llama al `AuthRepository`.
4. `AuthRepositoryImpl` crea la cuenta en Firebase Auth y escribe `usuarios/{uid}` en estado `pendiente`.
5. Si falla el guardado del perfil, se cierra la sesión.
6. Se muestra pantalla de éxito y se invita a iniciar sesión tras la aprobación.

---

## Credenciales de prueba

Ver [auth/login.md](./login.md).

---

## Documentación relacionada

- [../estado.md](../estado.md) — Autenticación: login, registro, perfil en Firestore.
- [../arquitectura.md](../arquitectura.md) — Redirección según estado de sesión.
- [../reglas-desarrollo.md](../reglas-desarrollo.md) — Nombres de campos de Firestore.
- [../flujos/auth/flujo-autenticacion.md](../flujos/auth/flujo-autenticacion.md) — Flujo completo de autenticación.
