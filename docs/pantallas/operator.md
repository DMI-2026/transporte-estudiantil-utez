# Pantalla: Panel operador (`/operador`)

Permite al operador ver salidas asignadas, la ruta, la lista de abordaje y el QR de cada estudiante.

---

## Ruta y acceso

| Atributo | Valor |
|----------|-------|
| Ruta | `/operador` |
| Rol | Operador (cuenta aprobada) |
| Acceso | Solo con sesión aprobada y rol `operador` |
| Layout | Pantalla con lista de salidas y abordaje |
| Registro de ruta | `lib/src/core/router/app_routes.dart` |

---

## Estado de implementación

**Stub** — Carpeta de feature creada, sin código de negocio.

---

## Diseño y secciones

- Lista de salidas asignadas al operador.
- Detalle de la salida con ruta y paradas.
- Lista de abordaje con estudiantes reservados.
- Mostrar y validar QR de abordaje.
- Ubicación en primer plano durante el recorrido.

---

## Archivos involucrados

```text
lib/src/features/operator/
├── domain/
│   ├── Salida.dart                  # Entidad (stub)
│   └── OperatorRepository.dart      # Contrato (stub)
├── data/
│   └── OperatorRepositoryImpl.dart  # Implementación (stub)
├── presentation/
│   ├── operator_cubit.dart          # Cubit (stub)
│   ├── operator_state.dart          # Estado (stub)
│   └── operator_page.dart           # Widget (stub)
test/
└── features/operator/
    └── operator_cubit_test.dart     # Pruebas (stub)
```

---

## Datos y contratos

| Colección | Documento | Campos relevantes |
|-----------|-----------|-------------------|
| `salidas` | automático | `programada`, `enCurso`, `finalizada`, `cancelada` |
| `reservas` | `{salidaId}_{uid}` | Estado de reserva y abordaje |

---

## Guía de construcción

1. Copiar el patrón de capas de `auth`.
2. Implementar `OperatorRepository` con lectura de salidas y reservas del operador.
3. Crear `OperatorCubit` con estados de carga, datos y error.
4. Crear `OperatorPage` con lista de salidas y lista de abordaje.
5. Agregar permisos de cámara (QR) y ubicación en primer plano.
6. Registrar dependencias en `injection.dart`.
7. Escribir pruebas en `test/features/operator/`.
8. Registrar la ruta en `app_routes.dart`.

---

## Documentación relacionada

- [../estado.md](../estado.md) — Feature `operator`: stub.
- [../modulos/operador.md](../modulos/operador.md) — Módulo operador.
- [../modulos/funcionalidades/qr.md](../modulos/funcionalidades/qr.md) — Validación de abordaje.
- [../servicios.md](../servicios.md) — Ubicación, cámara y QR (pendientes).
