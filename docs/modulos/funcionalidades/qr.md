# Funcionalidad: abordaje con QR

Estado: Hecho en contrato (Functions + UI estudiante). Features: `boarding` (estudiante muestra pase) y `operator` (escanea/valida).

## Almacenamiento

- El secreto del QR vive en `salidas/{salidaId}/privado/qr` (`qrSecret`, `qrExpiraEn`). Lo genera el operador con `generarQrSalida`. El estudiante **no** lee esa colección.
- El estudiante obtiene el payload del pase con el callable `obtenerPaseAbordaje` (solo si su reserva está `reservada`).

## Flujos

- Estudiante (`boarding/`): muestra un QR con payload `{reservaId}|{salidaId}|{qrSecret}` firmado en servidor. La app no registra el secreto en logs de release.
- Operador: escanea el QR y llama `validarQrAbordaje` (salidaId, reservaId, qrScaneado). La validación y el cambio a `abordada` son solo en Cloud Functions (D-06).
- El cliente Flutter nunca escribe `privado/qr` ni marca la reserva como abordada.

## Archivos clave

- Functions: `apps/firebase/functions/src/api/qr.ts`, `pase.ts`
- App: `apps/mobile/lib/src/features/boarding/`
