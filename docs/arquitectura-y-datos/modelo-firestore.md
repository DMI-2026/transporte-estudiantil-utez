# Modelo Firestore — UTEBus

Proyecto Firebase: **utebus-4435b**. Reglas versionadas en `firebase/firestore.rules`.

## Colecciones raíz

| Colección | ID documento | Descripción |
|-----------|--------------|-------------|
| `usuarios` | `{uid}` Auth | Perfil, rol, verificación |
| `rutas` | auto | Catálogo de rutas |
| `paradas` | auto | Paradas por ruta |
| `salidas` | auto | Viajes programados / en curso |
| `reservas` | `{salidaId}_{uid}` | Cupo por estudiante |
| `pagos` | auto | Checkout Mercado Pago (MVP) |
| `reportes` | auto | Incidencias |

## Subcolecciones

| Ruta | Uso |
|------|-----|
| `usuarios/{uid}/dispositivos/{deviceId}` | Tokens FCM |
| `salidas/{salidaId}/privado/qr` | Documento con secreto QR (operador/admin; escritura Functions) |

## Campos por colección

### `usuarios`

| Campo | Tipo | Notas |
|-------|------|--------|
| `email` | string | |
| `nombreCompleto` | string | opcional al registro |
| `rol` | string | `estudiante` \| `operador` \| `administrador` |
| `estadoVerificacion` | string | `pendiente` \| `aprobada` \| `rechazada` |
| `creadoEn` | timestamp | |
| `actualizadoEn` | timestamp | opcional |

El cliente no puede cambiar `rol`, `estadoVerificacion`, `email` ni `creadoEn` de su propio documento (solo el administrador). Un valor desconocido en `rol` o `estadoVerificacion` hace que la app trate el perfil como inválido.

### `rutas`

| Campo | Tipo |
|-------|------|
| `nombre` | string |
| `descripcion` | string |
| `activa` | bool |
| `polyline` | string | encoded polyline (Routes API) |
| `creadoEn`, `actualizadoEn` | timestamp |

### `paradas`

| Campo | Tipo |
|-------|------|
| `rutaId` | string |
| `nombre` | string |
| `orden` | number |
| `ubicacion` | geopoint |
| `activa` | bool |

### `salidas`

| Campo | Tipo |
|-------|------|
| `rutaId` | string |
| `operadorId` | string (uid) |
| `fechaHoraSalida` | timestamp |
| `estado` | string | `programada` \| `enCurso` \| `finalizada` \| `cancelada` |
| `asientosTotales` | number |
| `asientosDisponibles` | number |
| `ubicacionActual` | geopoint | operador durante `enCurso` |
| `actualizadoEn` | timestamp |

### `reservas`

| Campo | Tipo |
|-------|------|
| `salidaId` | string |
| `estudianteId` | string (uid) |
| `paradaId` | string |
| `estado` | string | `pendientePago` \| `reservada` \| `cancelada` \| `abordada` |
| `creadaEn` | timestamp |
| `actualizadoEn` | timestamp |

Creación atómica con decremento de `asientosDisponibles` (app o Function).

### `pagos`

| Campo | Tipo |
|-------|------|
| `reservaId` | string |
| `salidaId` | string |
| `estudianteId` | string |
| `monto` | number |
| `moneda` | string | ej. `MXN` |
| `estado` | string | `pendiente` \| `aprobado` \| … — **`aprobado` solo Admin SDK** |
| `proveedor` | string | `mercadoPago` |
| `externalId` | string | id preferencia MP |
| `creadoEn` | timestamp |

### `reportes`

| Campo | Tipo |
|-------|------|
| `reportadoPor` | string (uid) |
| `salidaId` | string | opcional |
| `tipo` | string |
| `descripcion` | string |
| `estado` | string | `abierto` \| `enRevision` \| `cerrado` |
| `fotoUrl` | string | Storage |
| `creadoEn` | timestamp |

## Índices compuestos

Definidos en `firebase/firestore.indexes.json` (consultas por ruta, operador, estudiante, verificación).

## Datos de demostración

En **producción** hay documentos `demo-*` (estudiante, operador, admin, ruta, paradas, salida, reserva, pago, reporte). Los uids demo **no** crean usuarios en Authentication automáticamente.

Volver a cargar (requiere service account en `env/firebase-admin-sa.json` o `GOOGLE_APPLICATION_CREDENTIALS`; las reglas no se tocan):

```powershell
.\scripts\seed-firestore-prod.ps1
```

Último recurso sin service account: `.\scripts\seed-firestore-prod.ps1 -AbrirReglas` abre Firestore temporalmente y restaura las reglas al terminar. No usar con datos reales.
