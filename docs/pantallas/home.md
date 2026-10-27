# Pantalla: Inicio (`/inicio`)

Pantalla principal del estudiante tras iniciar sesión. Muestra saludo y permite cerrar sesión.

---

## Ruta y acceso

| Atributo | Valor |
|----------|-------|
| Ruta | `/inicio` |
| Rol | Estudiante (cuenta aprobada) |
| Acceso | Solo con sesión aprobada |
| Layout | Pantalla con barra superior y contenido principal |
| Registro de ruta | `lib/src/core/router/app_routes.dart` |

---

## Estado de implementación

**Activo** — Muestra saludo y botón de cerrar sesión. Pendiente: próxima reserva y tiempo estimado de llegada.

---

## Diseño y secciones

- Saludo personalizado con el nombre del estudiante.
- Información de la próxima salida (pendiente de implementar).
- Botón de cerrar sesión.
- Estados de carga y error mediante `UiState` + `UiStateView` + `MensajeEstado`.

---

## Archivos involucrados

```text
lib/src/features/home/
├── domain/
│   └── HomeRepository.dart          # Contrato (pendiente)
├── data/
│   └── HomeRepositoryImpl.dart      # Implementación (pendiente)
├── presentation/
│   ├── home_cubit.dart              # Cubit (pendiente)
│   ├── home_state.dart              # Estado (pendiente)
│   └── home_page.dart               # Widget de la pantalla
test/
└── features/home/
    └── home_cubit_test.dart         # Pruebas (pendiente)
```

---

## Datos y contratos

| Colección | Documento | Campos relevantes |
|-----------|-----------|-------------------|
| `salidas` | automático | `programada`, `enCurso`, `finalizada`, `cancelada` |
| `usuarios` | `{uid}` | `rol`, `estadoVerificacion` |

---

## Guía de construcción

1. Verificar que la sesión esté aprobada antes de mostrar la pantalla.
2. Cargar datos del usuario desde `usuarios/{uid}`.
3. (Pendiente) Cargar próxima salida reservada del estudiante.
4. Implementar cierre de sesión mediante `AuthSessionCubit`.

---

## Credenciales de prueba

Ver [auth/login.md](./auth/login.md).

---

## Documentación relacionada

- [../estado.md](../estado.md) — Feature `home`: activo (saludo y cerrar sesión).
- [../modulos/estudiante.md](../modulos/estudiante.md) — Módulo estudiante, sección home.
- [../arquitectura.md](../arquitectura.md) — Router y redirección por sesión.
