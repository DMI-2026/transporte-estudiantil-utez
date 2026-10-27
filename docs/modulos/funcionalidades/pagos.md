# Funcionalidad: pagos

Pago digital y confirmación del asiento con Mercado Pago Checkout Pro y webhooks en Cloud Functions. Estado: pendiente.

## Reglas

- La reserva puede quedar en `pendientePago` hasta que el servidor confirme el pago.
- Colección `pagos`: el cliente solo crea documentos con `estado = pendiente`. El estado `aprobado` lo escribe únicamente el Admin SDK desde Cloud Functions, nunca la app Flutter.
- Tras un webhook válido, la función actualiza la reserva a `reservada` en una transacción.

## Secretos

Las claves de Mercado Pago y la service account van en el entorno de Cloud Functions o de CI; nunca en el repositorio. Ver [servicios.md](../../servicios.md).

Flutter solo maneja el deep link de retorno del checkout. No se confía en parámetros de la URL como prueba de pago.
