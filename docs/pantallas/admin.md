# Pantalla: Panel de administración (web)

Panel web para que el administrador verifique cuentas, gestione el catálogo de rutas y salidas. Implementación oficial pendiente (carpeta `admin-web/`).

---

## Ruta y acceso

| Atributo | Valor |
|----------|-------|
| Ruta | — (panel web aparte) |
| Rol | Administrador |
| Acceso | Solo con sesión de administrador |
| Layout | Panel web sobre el mismo Firebase |
| Registro de ruta | — |

---

## Estado de implementación

**Pendiente** — No implementado en el repositorio Flutter. La administración oficial será un panel web aparte.

---

## Diseño y secciones

- Verificación de cuentas de estudiantes y operadores (aprobar / rechazar).
- Gestión del catálogo: rutas, paradas y salidas.
- Visualización de reservas y abordajes.
- Auditoría de acciones administrativas.

---

## Archivos involucrados

```text
admin-web/         # Pendiente (no está en este repositorio Flutter)
firebase/
  firestore.rules  # Reglas para administrador
  storage.rules    # Reglas de Storage
```

---

## Datos y contratos

| Colección | Documento | Campos relevantes |
|-----------|-----------|-------------------|
| `usuarios` | `{uid}` | `rol`, `estadoVerificacion` |
| `rutas` | automático | Catálogo de rutas |
| `paradas` | automático | Paradas de cada ruta |
| `salidas` | automático | `programada`, `enCurso`, `finalizada`, `cancelada` |

---

## Guía de construcción

1. Definir alcance del panel web en un issue de GitHub.
2. Elegir tecnología del panel web (no está definida aún).
3. Implementar verificación de cuentas con reglas de Firestore de privilegio mínimo.
4. Implementar gestión de catálogo (rutas, paradas, salidas).
5. Revisar [arquitectura-y-datos/reglas-seguridad.md](../arquitectura-y-datos/reglas-seguridad.md).

---

## Documentación relacionada

- [../estado.md](../estado.md) — Administración: pendiente.
- [../modulos/administrador.md](../modulos/administrador.md) — Módulo administrador.
- [../arquitectura.md](../arquitectura.md) — Backend: `admin-web/` pendiente.
- [../servicios.md](../servicios.md) — Administración: panel web sobre Firebase (pendiente).
