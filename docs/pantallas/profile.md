# Pantalla: Perfil (`/perfil`)

Permite al estudiante gestionar su perfil, privacidad, notificaciones y eliminar su cuenta (derechos ARCO).

---

## Ruta y acceso

| Atributo | Valor |
|----------|-------|
| Ruta | `/perfil` |
| Rol | Estudiante (cuenta aprobada) |
| Acceso | Solo con sesión aprobada |
| Layout | Pantalla de configuración de perfil |
| Registro de ruta | `lib/src/core/router/app_routes.dart` |

---

## Estado de implementación

**Stub** — Carpeta de feature creada, sin código de negocio.

---

## Diseño y secciones

- Datos del perfil: nombre, apellidos, correo, rol.
- Aviso de privacidad.
- Activar o desactivar notificaciones push.
- Opción de eliminar cuenta (derechos ARCO).
- Nota: el cliente no cambia `rol` ni `estadoVerificacion`.

---

## Archivos involucrados

```text
lib/src/features/profile/
├── domain/
│   └── ProfileRepository.dart       # Contrato (stub)
├── data/
│   └── ProfileRepositoryImpl.dart   # Implementación (stub)
├── presentation/
│   ├── profile_cubit.dart           # Cubit (stub)
│   ├── profile_state.dart           # Estado (stub)
│   └── profile_page.dart            # Widget (stub)
test/
└── features/profile/
    └── profile_cubit_test.dart      # Pruebas (stub)
```

---

## Datos y contratos

| Colección | Documento | Campos relevantes |
|-----------|-----------|-------------------|
| `usuarios` | `{uid}` | `rol`, `estadoVerificacion`, datos de perfil |

---

## Guía de construcción

1. Copiar el patrón de capas de `auth` (domain/data/presentation).
2. Implementar `ProfileRepository` con lectura y actualización de `usuarios/{uid}`.
3. Implementar `ProfileCubit` con estados de carga, éxito y error.
4. Crear `ProfilePage` con formulario de perfil y opciones de privacidad.
5. Implementar eliminación de cuenta con confirmación.
6. Registrar dependencias en `injection.dart`.
7. Escribir pruebas en `test/features/profile/`.
8. Registrar la ruta en `app_routes.dart`.

---

## Documentación relacionada

- [../estado.md](../estado.md) — Feature `profile`: stub.
- [../modulos/estudiante.md](../modulos/estudiante.md) — Módulo estudiante, sección profile.
- [../reglas-desarrollo.md](../reglas-desarrollo.md) — Capas y reutilización.
