# Funcionalidad: reservas

Feature: `lib/src/features/reservations/`. Estado: pendiente. Cubre reservar asiento y, cuando hay cobro, la confirmación tras el pago.

## Reglas de negocio

- Transacción atómica: crear el documento de reserva y decrementar `asientosDisponibles` en la salida.
- Id de reserva: `{salidaId}_{uid}` (la regla de Firestore lo exige).
- Estados: `pendientePago` cuando hay cobro, `reservada` en modo gratuito.
- Edición: cambiar `paradaId` solo si la salida sigue en `programada`.
- No confirmar el pago solo por volver del checkout; ver [pagos.md](pagos.md).

## Firestore

Campo de fecha acordado: `creadaEn` en reservas. Ver [reglas-desarrollo.md](../../reglas-desarrollo.md).
