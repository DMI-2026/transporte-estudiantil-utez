# Cloud Functions — UTEBus (pendiente de implementar)

Proyecto Firebase: **utebus-4435b**.

Este documento define las funciones esperadas, sus triggers y responsabilidades. Ninguna función está implementada aún en el repositorio.

---

## Funciones previstas

| Función | Trigger | Responsabilidad | Estado |
|---------|---------|-----------------|--------|
| `generarQR` | `salidas/{salidaId}/privado/qr` (write) o HTTP callable | Genera el secreto QR de una salida y lo escribe en la subcolección protegida | Pendiente |
| `procesarPago` | Webhook de Mercado Pago | Confirma el pago, actualiza `pagos/{pagoId}.estado = aprobado` y cambia reserva a `reservada` | Pendiente |
| `notificarReserva` | `reservas/{reservaId}` (create/update) | Envía notificación push (FCM) al estudiante cuando su reserva cambia de estado | Pendiente |
| `aprobarCuenta` | HTTP callable (admin) | Cambia `usuarios/{uid}.estadoVerificacion` a `aprobada` o `rechazada`; opcionalmente asigna custom claim de rol | Pendiente |
| `actualizarPosicionOperador` | `salidas/{salidaId}` (update) | Valida y persiste la ubicación actual del operador durante `enCurso` | Pendiente |
| `cerrarSalida` | Scheduler o HTTP callable | Pone salida en `finalizada` y libera cupos no ocupados | Pendiente |

---

## Reglas de seguridad aplicables

- El cliente Flutter **nunca** escribe `pagos/{pagoId}.estado = aprobado`.
- El cliente Flutter **nunca** escribe `salidas/{id}/privado/qr`.
- Solo Cloud Functions (Admin SDK) puede actualizar pagos a aprobado y escribir secretos QR.
- La función `aprobarCuenta` solo puede ser invocada por un administrador autenticado.

---

## Estructura sugerida de `functions/`

```text
functions/
├── src/
│   ├── index.ts            # punto de entrada, exporta todas las funciones
│   ├── qr.ts               # generarQR
│   ├── pagos.ts            # procesarPago (webhook MP)
│   ├── notificaciones.ts   # notificarReserva
│   ├── admin.ts            # aprobarCuenta
│   ├── salidas.ts          # actualizarPosicionOperador, cerrarSalida
│   └── utils/
│       ├── admin-sdk.ts    # inicialización de Admin SDK
│       └── validaciones.ts # validaciones compartidas
├── package.json
├── tsconfig.json
└── firebase.json (configuración de functions en la raíz del repo)
```

---

## Variables de entorno (no versionar)

| Variable | Uso |
|----------|-----|
| `MERCADO_PAGO_ACCESS_TOKEN` | Webhook de pagos |
| `MERCADO_PAGO_WEBHOOK_SECRET` | Validación de webhook MP |
| `FCM_SERVER_KEY` (opcional) | Envío de push notifications |

---

## Despliegue

```bash
cd funciones   # o carpeta functions/
npm install
npm run build  # si usa TypeScript
firebase deploy --only functions --project utebus-4435b
```

Requiere plan **Blaze** de Firebase para Cloud Functions y webhooks externos.

---

## Documentación relacionada

- [modelo-firestore.md](./modelo-firestore.md) — Colecciones y campos.
- [reglas-seguridad.md](./reglas-seguridad.md) — Reglas de Firestore y Storage.
- [servicios.md](../servicios.md) — Integraciones y estado de servicios.
