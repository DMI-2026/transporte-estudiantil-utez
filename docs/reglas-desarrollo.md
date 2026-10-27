# Reglas de desarrollo

Para personas y agentes de IA. Prioridad: mismo patrón que el código existente, cambio mínimo, sin secretos.

Git, sensor de verificación y la tabla de convenciones C-01 a C-12 están en [convenciones.md](convenciones.md), que manda sobre este archivo en ramas, commits y cómo verificar. Este archivo cubre las capas Flutter, los nombres de Firestore y la seguridad en el código.

Flujo de tarea, validación, reporte y cuándo tocar documentación: [README.md](README.md). Estados (Hecho, Local, Pendiente, Propuesto, No usar): [README, sección Estados de decisión](README.md#estados-de-decisión).

Protección del trabajo: no revertir cambios ajenos al issue, no borrar archivos sin comprobar referencias, no commits con secretos.

## Reutilización

- Extender `lib/src/core/` (tema, router, logger, inyección de dependencias) antes de crear utilidades paralelas.
- Las pantallas nuevas van dentro de su feature (`domain/`, `data/`, `presentation/`); nada de lógica en `main.dart`.
- Tema: `AppColors`, `AppSpacing`, `AppRadii`, `AppTheme`. No usar colores hexadecimales sueltos salvo excepción documentada.
- Toda pantalla que carga datos remotos usa `UiState` + `UiStateView` y muestra errores o vacíos con `MensajeEstado`.
- El feature `auth` es la referencia de cómo se estructura una feature completa, con pruebas y fakes.

## Nombres y lógica

- Mantener los nombres de campos de Firestore acordados (`creadaEn` en reservas, `creadoEn` en pagos y usuarios).
- Id de reserva: `{salidaId}_{uid}`.
- No renombrar features ni carpetas sin un issue explícito.

## Responsabilidades por capa

| Capa | Permite | Prohíbe |
|------|---------|---------|
| presentation | Widgets, Cubits, llamadas al repositorio del dominio | Firestore, Auth o HTTP directo; `get_it` desde widgets para la sesión (usar `context.read<AuthSessionCubit>()`) |
| domain | Entidades, contratos de repositorio, validadores | Widgets de Flutter, SDK de Firebase |
| data | Datasources, mappers, implementación del repositorio | `BuildContext` |

Registrar las dependencias nuevas en `lib/src/core/di/injection.dart`.

## Estado de UI

- Toda la lógica de pantalla va en un Cubit (`flutter_bloc`) con estado `Equatable`. No introducir `ChangeNotifier` ni otro gestor de estado.
- La sesión global está en `AuthSessionCubit`. El router la observa a través de `StreamListenable` para redirigir.

## Responsividad

- Usar `Theme` y `MediaQuery`; paddings y márgenes con `AppSpacing`.
- Listas largas con `ListView` o `CustomScrollView`; nunca un `Column` sin scroll en pantallas pequeñas.
- Probar al menos en un ancho de unos 360 píxeles lógicos.

## Errores y experiencia de usuario

- Los errores de red o de Firebase se traducen a un `AppFailure` en `data/`. La UI muestra `userMessage`, nunca el error técnico ni un stack trace.
- `AppLogger`: no registrar correos, tokens de QR ni coordenadas en release.
- Modo sin conexión (pendiente): aviso con botón Reintentar.

## Seguridad

- Sin secretos en git (lista en [servicios.md](servicios.md)).
- `pagos.estado = aprobado` lo escribe solo el Admin SDK desde Cloud Functions.
- El secreto del QR vive en `salidas/{salidaId}/privado/qr`; el cliente nunca lo escribe.
- Un rol o estado de verificación desconocido se trata como perfil inválido; nunca se asume un rol por defecto.
- Reglas de Firestore y Storage con privilegio mínimo: [arquitectura-y-datos/reglas-seguridad.md](arquitectura-y-datos/reglas-seguridad.md).

## Git y PR

- Rama `feat/<issue>-<slug>` desde `develop`.
- Commits en español, en imperativo, con Conventional Commits.
- El PR incluye `Closes #N` y la salida de la verificación ejecutada.
- Nunca push directo a `main` ni a `develop`.

## Duplicación

- No copiar lógica entre features. Extraer a `core/` solo cuando haya dos o más consumidores.
- No agregar dependencias que el issue no pide; las que se agreguen deben ser de publisher verificado.

## Pruebas obligatorias antes del PR

El único comando de "listo" (convención C-04) es `.\scripts\check.ps1`. El hook pre-commit lo ejecuta (`git config core.hooksPath .githooks`). `.\scripts\verify-activity.ps1` es un extra para cerrar issues y no lo sustituye.

Cada clase con lógica (repositorio, Cubit, mapper, validador) tiene su prueba en `test/`, espejo de `lib/`, usando los fakes de `test/fakes/`.

## Permisos del dispositivo

Estudiante: cámara o galería para la credencial, ubicación bajo demanda para la parada cercana, notificaciones push. Operador: cámara para el QR, ubicación en primer plano durante el recorrido, notificaciones push, selector de contactos para incidentes (el número no se guarda).

Los textos de cada permiso en `AndroidManifest.xml` e `Info.plist` se redactan al implementar la pantalla que lo usa. Tabla completa: [referencia-dmi.md](referencia-dmi.md).
