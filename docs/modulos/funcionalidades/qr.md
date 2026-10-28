# Funcionalidad: abordaje con QR

Estado: pendiente. Features involucradas: `operator` (muestra el QR) y `boarding` (lo escanea).

## Almacenamiento

- El secreto del QR vive en el documento `salidas/{salidaId}/privado/qr`. Lo lee el operador asignado o el administrador; la app del estudiante no lo lee y ningún cliente lo escribe (regla `match /privado/{docId}` en `firebase/firestore.rules`).

## Flujos

- Operador: muestra un QR rotativo o estático según el diseño del issue (pantalla en `operator/`).
- Estudiante: escanea en `boarding/`; la validación la hace una Cloud Function callable, no el cliente.
- El cliente no registra el contenido del QR en logs de release ([reglas-desarrollo.md](../../reglas-desarrollo.md)).
