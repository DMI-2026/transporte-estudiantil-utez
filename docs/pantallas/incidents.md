# Pantalla: Incidencias (`/incidencias`)

Permite al estudiante crear y consultar reportes de incidencias, con foto opcional en Storage.

---

## Ruta y acceso

| Atributo | Valor |
|----------|-------|
| Ruta | `/incidencias` |
| Rol | Estudiante |
| Acceso | Solo con sesión aprobada |
| Layout | Pantalla de formulario y lista de reportes |
| Registro de ruta | `lib/src/core/router/app_routes.dart` |

---

## Estado de implementación

**Stub** — Carpeta de feature creada, sin código de negocio.

---

## Diseño y secciones

- Formulario para crear una incidencia (título, descripción, foto opcional).
- Lista de reportes abiertos del estudiante.
- Estados de reporte: `abierto`, `enRevision`, `cerrado`.
- Foto de incidencia subida a Cloud Storage en `reportes/{uid}/`.
- Selector de contactos para incidentes (el número no se guarda).

---

## Archivos involucrados

```text
lib/src/features/incidents/
├── domain/
│   ├── Incidente.dart               # Entidad (stub)
│   └── IncidentsRepository.dart     # Contrato (stub)
├── data/
│   └── IncidentsRepositoryImpl.dart # Implementación (stub)
├── presentation/
│   ├── incidents_cubit.dart         # Cubit (stub)
│   ├── incidents_state.dart         # Estado (stub)
│   └── incidents_page.dart          # Widget (stub)
test/
└── features/incidents/
    └── incidents_cubit_test.dart    # Pruebas (stub)
```

---

## Datos y contratos

| Colección | Documento | Campos relevantes |
|-----------|-----------|-------------------|
| `reportes` | automático | `abierto`, `enRevision`, `cerrado` |
| `reportes/{uid}/` | (Storage) | Foto de la incidencia |

---

## Guía de construcción

1. Copiar el patrón de capas de `auth`.
2. Agregar dependencias pendientes: `image_picker`, `firebase_storage`.
3. Implementar `IncidentsRepository` con escritura en `reportes` y Storage.
4. Crear `IncidentsCubit` con estados de carga, éxito y error.
5. Crear `IncidentsPage` con formulario y lista de reportes.
6. Agregar permiso de cámara o galería en `AndroidManifest.xml` e `Info.plist`.
7. Registrar dependencias en `injection.dart`.
8. Escribir pruebas en `test/features/incidents/`.
9. Registrar la ruta en `app_routes.dart`.

---

## Documentación relacionada

- [../estado.md](../estado.md) — Feature `incidents`: stub.
- [../modulos/estudiante.md](../modulos/estudiante.md) — Módulo estudiante, sección incidents.
- [../servicios.md](../servicios.md) — Cloud Storage y CamaraService (pendientes).
- [../referencia-dmi.md](../referencia-dmi.md) — Permisos del dispositivo.
