# Documentación — transporte-estudiantil-utez

Documentación mínima pensada para que una persona o un agente de IA pueda tomar un issue de GitHub, ubicar los archivos y resolverlo sin romper la arquitectura.

Código canónico: `lib/` en la raíz del repositorio.

## Orden de lectura según la tarea

| Paso | Documento | Cuándo leerlo |
|------|-----------|---------------|
| 1 | Este README (protocolo y cierre) | Siempre |
| 2 | [reglas-desarrollo.md](reglas-desarrollo.md) y [convenciones.md](convenciones.md) | Siempre: capas Flutter, Git y sensor de verificación |
| 3 | [modulos/README.md](modulos/README.md) | Cuando el issue toca una feature o un rol |
| 4 | [servicios.md](servicios.md) | Cuando toca Firebase, paquetes o APIs externas |
| 5 | [arquitectura.md](arquitectura.md) | Cuando cambia la estructura de carpetas, rutas o datos |
| 6 | [estado.md](estado.md) | Para saber qué está hecho y qué bloquea una feature |
| 7 | [referencia-dmi.md](referencia-dmi.md) | Cuando el issue cita historias de usuario o requisitos del enunciado |

## Protocolo de tarea

Obligatorio para Cursor y Claude (entrada: [AGENTS.md](../AGENTS.md) y [CLAUDE.md](../CLAUDE.md)).

1. **Analizar** el título, la descripción, los criterios de aceptación y las restricciones del issue. Si no hay criterios explícitos, inferir el resultado esperado sin inventar requisitos.
2. **Leer** este README y [reglas-desarrollo.md](reglas-desarrollo.md). Abrir solo las secciones relevantes de arquitectura, servicios y módulo.
3. **Inspeccionar** el código real: pantallas, widgets, router, modelos, inyección de dependencias, servicios y pruebas (buscar con `grep` y abrir archivos).
4. **Identificar** el cambio mínimo. Reutilizar `core/` y los patrones que ya existen (el feature `auth` es la referencia).
5. **Implementar** solo el alcance del issue, respetando arquitectura, seguridad, responsividad y convenciones.
6. **Resolver ambigüedades** con el código cuando sea posible. Preguntar solo si falta una decisión que no se puede inferir.
7. **Validar** según la sección [Validación](#validación). No afirmar pruebas que no se ejecutaron.
8. **Revisar el diff** en busca de cambios accidentales, duplicación o documentación que quedó desactualizada.
9. **Documentar** solo si aplica la sección [Cuándo actualizar documentación](#cuándo-actualizar-documentación).
10. **Reportar** con el formato de la sección [Reporte final](#reporte-final).

### Plantilla mínima para pegar junto con el issue

```markdown
Issue: #N — <título>
Rama: feat/N-slug
Docs: docs/modulos/<rol | funcionalidades/...> y docs/servicios.md si aplica
Alcance incluido: <lista>
Alcance excluido: <lista>
Archivos permitidos: <rutas>
Criterio de terminado: <del issue>
Verificación: .\scripts\check.ps1 (y .\scripts\verify-activity.ps1 -Tipo <base|feature|firebase|rules> si aplica)
```

## Cuándo actualizar documentación

| Archivo | Actualizar cuando | No tocar cuando |
|---------|-------------------|-----------------|
| [arquitectura.md](arquitectura.md) | Cambian capas, el árbol de `lib/`, flujos de datos o una decisión arquitectónica confirmada | Solo cambia el aspecto o el texto de una pantalla |
| [servicios.md](servicios.md) | Cambian integraciones, dependencias en `pubspec`, configuración verificada o el estado de un servicio | El issue no toca backend ni paquetes |
| [modulos/](modulos/) | Cambian flujos, rutas, reglas de negocio, permisos o archivos clave de la feature | Refactor interno sin cambio de comportamiento documentado |
| [convenciones.md](convenciones.md) | Cambia alguna convención C-01 a C-12 o el sensor de verificación | El issue ya sigue la convención |
| [reglas-desarrollo.md](reglas-desarrollo.md) | Cambian convenciones aprobadas por el equipo | Una pantalla sigue una regla ya escrita |
| Este README | Cambia el procedimiento general, el arranque o el reparto del equipo | Tarea puntual ya cubierta en el módulo |
| [referencia-dmi.md](referencia-dmi.md) | Se corrige la trazabilidad con el enunciado (issue de alcance) | La implementación ya corresponde a una fila existente |
| [ia/bitacora.md](ia/bitacora.md) | Decisión técnica importante (motivo y consecuencia) | Commits rutinarios o cambios menores |

Nunca marcar como hecho algo que solo está propuesto. Usar los estados de la siguiente sección.

## Estados de decisión

En toda la documentación los estados se escriben con palabras, no con símbolos.

| Estado | Significado |
|--------|-------------|
| **Hecho** | Implementado y verificado en el repositorio |
| **Local** | Configurado en la máquina de cada desarrollador; no se versiona |
| **Pendiente** | Acordado o planificado, todavía no está en código |
| **Propuesto** | Discutido pero sin aprobación; requiere decisión antes de implementar |
| **No usar** | Descartado; no debe implementarse |
| **stub** | Carpeta de feature con `.gitkeep`, sin código de negocio |
| **activo** | Feature con código Dart usable |

## Validación

Ejecutar lo que aplique al alcance y al entorno disponible:

| Alcance | Comando |
|---------|---------|
| Verificar todo (criterio único de "listo", convención C-04) | `.\scripts\check.ps1` |
| Cierre general de issue (secretos, Firebase) | `.\scripts\verify-activity.ps1 -Tipo base` |
| Feature concreta | `.\scripts\verify-activity.ps1 -Tipo feature -Feature <nombre>` |
| Firebase o reglas | `.\scripts\verify-activity.ps1 -Tipo firebase` o `-Tipo rules` (incluye emulador) |
| Integración del arranque | `flutter test integration_test -d flutter-tester` |

Además: comprobar responsividad en pantallas nuevas (ancho de unos 360 píxeles lógicos), revisar el diff a mano y actualizar enlaces de documentación si se movieron archivos.

## Reporte final

Entregar al cerrar la tarea, con datos reales y sin relleno:

```markdown
## Implementación
<Qué se hizo, en dos a cuatro frases>

## Archivos
<Lista de rutas creadas o modificadas>

## Documentación
<Qué documentos se actualizaron, o "ninguna: no aplicaba">

## Pruebas
<Comandos ejecutados y resultado: pasó, falló u omitido, con motivo>

## Pendientes y decisiones
<Lo que requiere aprobación, lo que quedó fuera de alcance, limitaciones del entorno>
```

## Protección del trabajo previo

- No revertir cambios locales del usuario ni sobrescribir archivos fuera del alcance del issue.
- No ejecutar operaciones destructivas (`git reset --hard`, borrado masivo) salvo petición explícita.
- No eliminar documentación ni código sin comprobar referencias e información única.
- Diff mínimo: no refactorizar ni agregar dependencias que el issue no pide.

## Ejecución comprobada

```powershell
cd transporte-estudiantil-utez
git checkout develop
flutter pub get
.\scripts\setup-local.ps1
flutter run --dart-define-from-file=env/dev.json
git config core.hooksPath .githooks
.\scripts\check.ps1
.\scripts\verify-activity.ps1 -Tipo base
```

- `env/dev.json` se copia de `env/example.json` y no se versiona. Claves nativas: [arquitectura.md, sección Configuración local](arquitectura.md#configuración-local).
- Firebase: `USE_FIREBASE=true` solo cuando existan `lib/firebase_options.dart` y `android/app/google-services.json` en local.

## Propósito del producto

App Flutter para estudiante y operador, más un panel web de administración (pendiente), sobre Firebase: reservas de asiento, mapa de la combi, abordaje con QR y pagos procesados en Cloud Functions.

| Dato | Valor verificado |
|------|------------------|
| Package | `mx.edu.utez.transporte_estudiantil` |
| Proyecto Firebase | `utebus-4435b` |
| Rama de integración | `develop` |
| Figma | [Prototipo](https://www.figma.com/design/OjsdoVtcBMdcOSAFz85qWC/Transporte-Exclusivo-Estudiantil-%E2%80%94-UTEZ?node-id=3-2) |

Trazabilidad con el enunciado: [referencia-dmi.md](referencia-dmi.md). Necesidades por rol: issue #41.

## Estructura de esta carpeta

| Archivo o carpeta | Contenido |
|-------------------|-----------|
| [arquitectura.md](arquitectura.md) | Capas, árbol de `lib/`, router, Firestore |
| [estado.md](estado.md) | Hecho frente a pendiente (Firebase y módulos) |
| [arquitectura-y-datos/](arquitectura-y-datos/) | Modelo Firestore, reglas, seed |
| [convenciones.md](convenciones.md) | Convenciones C-01 a C-12, mapa con la plantilla del curso, qué no se iguala |
| [reglas-desarrollo.md](reglas-desarrollo.md) | Reutilización, seguridad, PR |
| [servicios.md](servicios.md) | Integraciones hechas y pendientes (issue #46) |
| [modulos/](modulos/) | Features por rol y funcionalidades transversales |
| [referencia-dmi.md](referencia-dmi.md) | Trazabilidad con funcionalidades, permisos e historias del enunciado |
| [media/arquitectura-capas.png](media/arquitectura-capas.png) | Diagrama de capas |
| [ia/bitacora.md](ia/bitacora.md) | Decisiones técnicas relevantes del curso |

## Reparto sugerido (seis integrantes)

| Persona | Herramienta | Enfoque inicial |
|---------|-------------|-----------------|
| Juan | Cursor | `routes_map`, mapas (cuando el paquete esté en `pubspec`) |
| Hanna | Cursor | `auth`, `profile` |
| David | Cursor | `home`, `trip`, modo sin conexión |
| Coordinación | Cursor | PR, `verify-activity`, `reservations` |
| Alison | Claude | `functions/`, emulador, mantenimiento de reglas |
| Jesús | Claude | `functions/`, `admin-web/`, pagos |

Los issues de GitHub deben enlazar el módulo en la plantilla (`docs/modulos/...`).
