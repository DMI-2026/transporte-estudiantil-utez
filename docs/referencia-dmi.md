# Trazabilidad con el enunciado del curso

Relación entre lo que pide el enunciado de Desarrollo Móvil Integral y el código de este repositorio, sin repetir el enunciado ni las historias completas. La fuente ampliada son los issues #41 a #45 y el backlog de GitHub.

Los documentos del curso usan códigos cortos (por ejemplo "F1" o "P2"). En este repositorio no se usan: cada fila se nombra por lo que hace. Si un issue cita un código, búscalo aquí por su descripción.

Estados: ver [README, sección Estados de decisión](README.md#estados-de-decisión).

## Funcionalidades

| Funcionalidad | Feature o documento principal | Estado |
|---------------|-------------------------------|--------|
| Autenticación, registro y verificación de cuenta | `auth` · [estudiante.md](modulos/estudiante.md) | Hecho |
| Reservas, control de cupo e incidencias del estudiante | `reservations`, `incidents` · [funcionalidades/reservas.md](modulos/funcionalidades/reservas.md) | Pendiente |
| Rutas, mapa y catálogo (administrador) | `routes_map`, panel web · [funcionalidades/rutas.md](modulos/funcionalidades/rutas.md) | Pendiente |
| Abordaje con QR | `boarding`, `operator` · [funcionalidades/qr.md](modulos/funcionalidades/qr.md) | Pendiente |
| Pago digital y confirmación de asiento | Cloud Functions + `reservations` · [funcionalidades/pagos.md](modulos/funcionalidades/pagos.md) | Pendiente |
| Estados de pantalla (cargando, datos, error, vacío) | `core/widgets/`: `UiState`, `UiStateView`, `MensajeEstado` | Hecho |
| Modo sin conexión y reintento | `connectivity_plus` y aviso con botón Reintentar | Pendiente |

## Restricciones del sistema

| Restricción | Dónde se aplica |
|-------------|-----------------|
| Mensajes de error genéricos para el usuario, sin detalles técnicos | [reglas-desarrollo.md](reglas-desarrollo.md); `AppFailure.userMessage` |
| Perfil, privacidad y baja de cuenta (derechos ARCO) | `profile` (pendiente) |
| Dependencias solo de publishers verificados | [servicios.md](servicios.md) y revisión en PR |

Otras restricciones del enunciado se enlazan en cada issue al criterio concreto; no se amplían aquí sin un issue de alcance.

## Permisos del dispositivo

| Rol | Permiso | Uso |
|-----|---------|-----|
| Estudiante | Cámara o galería | Subir credencial para verificación |
| Estudiante | Ubicación bajo demanda | Encontrar la parada más cercana en el mapa |
| Estudiante | Notificaciones push | Avisos de salida y reserva |
| Operador | Cámara | Escanear o mostrar QR de abordaje |
| Operador | Ubicación en primer plano | Transmitir posición durante el recorrido |
| Operador | Notificaciones push | Avisos operativos |
| Operador o sistema | Contactos (selector) | Contacto para incidentes; el número no se guarda |

Los textos de cada permiso en `AndroidManifest.xml` e `Info.plist` se redactan al implementar la pantalla que lo usa.

## Historias de usuario

Detalle y criterios: issues #43 (reserva), #44 (seguimiento) y #45 (pago). Necesidades por rol: issue #41.

| Historia | Feature o rol |
|----------|---------------|
| Registro y acceso del estudiante | `auth` |
| Consultar rutas y paradas | `routes_map` |
| Reservar asiento | `reservations` |
| Pantalla de inicio con próxima salida | `home` |
| Seguimiento del viaje y tiempo estimado de llegada | `trip`, `routes_map` |
| Abordar con QR | `boarding` |
| Reportar una incidencia | `incidents` |
| Operador: ver salidas, ruta, lista de abordaje y QR | `operator` |
| Administrador: verificar cuentas, catálogo y salidas | panel web (pendiente) |
| Pagar y confirmar la reserva | [pagos.md](modulos/funcionalidades/pagos.md) |

En el PR, cita la historia por su nombre y cierra el issue con `Closes #N`.
