# Módulo operador: pantallas del Figma "02 App Operador"

Pantallas del rol operador agregadas en la rama `feat/operador`. Solo frontend: los datos vienen de una fuente de **demostración en memoria** (`DemoOperatorDataSource`), registrada en `apps/mobile/lib/src/core/di/injection.dart` (`_configureOperador`). No usa Firebase, GPS ni cámara; el backend real cambia solo esa fuente.

## Pantallas y rutas

| Figma | Pantalla | Ruta | Archivo (`features/operator/presentation/`) |
|-------|----------|------|---------|
| 04 | Mis salidas (pestaña Salidas) | `/operador` | `salidas/operador_salidas_page.dart` |
| 05 | Recorrido en curso | `/operador/recorrido/:salidaId` | `recorrido/recorrido_page.dart` |
| 11 | Finalizar recorrido | `/operador/recorrido/:salidaId/finalizar` | `recorrido/finalizar_recorrido_page.dart` |
| 06 | Validar abordaje (pestaña Abordaje) | `/operador/abordaje` | `abordaje/validar_abordaje_page.dart` |
| 07 | Lista de abordaje | `/operador/abordaje/:salidaId/lista` | `abordaje/lista_abordaje_page.dart` |
| 12 | QR no válido | `/operador/abordaje/:salidaId/no-valido?motivo=` | `abordaje/qr_no_valido_page.dart` |
| 09 | Mis reportes (pestaña Reportes) | `/operador/reportes` | `reportes/operador_reportes_page.dart` |
| 08 | Reportar incidente | `/operador/reportes/nuevo?salida=` | `reportes/reportar_operador_page.dart` |
| 10 | Mi perfil (pestaña Perfil) | `/operador/perfil` | `perfil/operador_perfil_page.dart` |

Las pantallas 01 a 03 (acceso, registro y verificación) no se duplicaron: ya existen en `auth` para ambos roles.

## Qué se cambió en archivos existentes

- `app_router.dart`: `/operador` muestra `OperadorSalidasPage` en lugar del placeholder, y se agrega `...operatorRoutes()` (definidas en `core/router/operator_routes.dart`).
- `app_routes.dart`: constantes de las rutas de arriba.
- `injection.dart`: `_configureOperador()`.
- `app.dart`: `OperatorProviders` expone `OperatorRepository` al árbol.

## Reglas cubiertas

- `UiState` en cada pantalla con datos: cargando, datos, vacío y error con reintentar.
- Validación del reporte (tipo, parada, 10 a 500 caracteres) con `ReporteValidator` de `incidents`.
- La lectura de QR es simulada. La validación real del QR firmado ocurre en Cloud Functions (D-06), nunca en la app.
- Explicación previa antes del permiso de cámara al adjuntar evidencia.
- Mensajes de usuario, nunca errores técnicos (`AppFailure`).

## Datos de demostración

- Salidas `SAL-001` (06:40, 12 reservas) y `SAL-005` (14:10, 9 reservas), ambas en Combi 01.
- Solo puede haber un recorrido en curso a la vez.
- En la lectura simulada, la **tercera** lectura devuelve un QR no válido, para revisar la pantalla 12.

## Pendiente (fuera del alcance de frontend)

| Qué | Issue |
|-----|-------|
| Salidas desde Firestore e iniciar/finalizar recorrido real | #83 |
| Transmitir ubicación GPS en primer plano | #84 |
| Escaneo con cámara y validación del QR en Cloud Functions | #85, #86 |
| Lista de abordaje en tiempo real | #87 |
| Documentos del operador en el registro (INE, licencia, comprobante) | Sin issue |
