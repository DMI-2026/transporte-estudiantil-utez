# Pantalla: Abordaje con QR (`/abordaje`)

Permite al estudiante mostrar su QR de abordaje y al operador validarlo al subir a la combi.

---

## Ruta y acceso

| Atributo | Valor |
|----------|-------|
| Ruta | `/abordaje` |
| Rol | Estudiante / Operador |
| Acceso | Solo con sesión aprobada y reserva activa |
| Layout | Pantalla con código QR y botón de validar |
| Registro de ruta | `lib/src/core/router/app_routes.dart` |

---

## Estado de implementación

**Stub** — Carpeta de feature creada, sin código de negocio.

---

## Diseño y secciones

- Estudiante: muestra QR de abordaje generado por Cloud Functions.
- Operador: escanea o valida el QR del estudiante.
- Secreto del QR vive en `salidas/{salidaId}/privado/qr`; el cliente nunca lo escribe.
- Estado de la reserva cambia a `abordada` tras validación exitosa.

---

## Archivos involucrados

```text
lib/src/features/boarding/
├── domain/
│   ├── AbordajeRepository.dart      # Contrato (stub)
│   └── QrSecret.dart                # Entidad (stub)
├── data/
│   └── AbordajeRepositoryImpl.dart  # Implementación (stub)
├── presentation/
│   ├── boarding_cubit.dart          # Cubit (stub)
│   ├── boarding_state.dart          # Estado (stub)
│   └── boarding_page.dart           # Widget (stub)
test/
└── features/boarding/
    └── boarding_cubit_test.dart     # Pruebas (stub)
```

---

## Datos y contratos

| Colección | Documento | Campos relevantes |
|-----------|-----------|-------------------|
| `salidas/{id}/privado/qr` | qr | Secreto del QR (solo Cloud Functions escribe) |
| `reservas` | `{salidaId}_{uid}` | Estado `abordada` tras validación |

---

## Guía de construcción

1. Copiar el patrón de capas de `auth`.
2. Agregar dependencias pendientes: `mobile_scanner`, `qr_flutter`.
3. Implementar `AbordajeRepository` para leer el secreto del QR (solo lectura desde cliente).
4. Crear `BoardingPage` para estudiante (mostrar QR) y operador (escane
ar QR).
5. El cliente nunca marca el pago como aprobado ni escribe el secreto del QR; eso es trabajo de Cloud Functions.
6. Registrar dependencias en `injection.dart`.
7. Escribir pruebas en `test/features/boarding/`.
8. Registrar la ruta en `app_routes.dart`.

---

## Documentación relacionada

- [../estado.md](../estado.md) — Feature `boarding`: stub.
- [../modulos/estudiante.md](../modulos/estudiante.md) — Módulo estudiante, sección boarding.
- [../modulos/operador.md](../modulos/operador.md) — Módulo operador, sección abordaje.
- [../modulos/funcionalidades/qr.md](../modulos/funcionalidades/qr.md) — Secreto del QR y validación de abordaje.
- [../servicios.md](../servicios.md) — Cloud Functions para QR (pendiente).
