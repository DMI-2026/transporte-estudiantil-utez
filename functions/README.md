# Cloud Functions — Transporte Estudiantil UTEZ

Backend serverless en Firebase Functions (TypeScript). **Único backend** del proyecto (regla C-07).

## Estructura de carpetas

```
functions/
├── src/
│   ├── index.ts              # Entry point - exporta todo
│   ├── api/                  # HTTPS Callable Functions (endpoints que llama el cliente Flutter)
│   │   ├── pagos.ts          # Mercado Pago: crear preferencia, webhook, reembolsos
│   │   ├── qr.ts             # QR abordaje: generar secreto, validar escaneo
│   │   ├── notificaciones.ts # FCM: push a usuarios, notificaciones masivas
│   │   ├── admin.ts          # Verificación cuentas: aprobar/rechazar/listar pendientes
│   │   └── catalogo.ts       # Salidas/GPS: crear, actualizar ubicación, iniciar/finalizar
│   ├── triggers/             # Firestore Triggers (reaccionan a cambios en BD)
│   │   ├── reservas.ts       # Notificaciones al crear/actualizar/borrar reserva
│   │   ├── salidas.ts        # Notificaciones al crear/actualizar salida
│   │   └── reportes.ts       # Notificaciones al crear/actualizar incidencia
│   ├── models/               # Interfaces TypeScript compartidas (DTOs)
│   │   ├── pagos.ts          # PaymentPreferenceRequest, PaymentWebhookPayload, etc.
│   │   ├── usuarios.ts       # UserDocument, UserCustomClaims, DeviceTokenDocument
│   │   └── operacion.ts      # ReservaDocument, SalidaDocument, RutaDocument, ReporteDocument
│   ├── services/             # Wrappers de servicios externos
│   │   └── mercadopago.ts    # Cliente Mercado Pago tipado
│   └── utils/                # Helpers internos
│       ├── firestore.ts      # Transacciones, batch writes, paginación
│       └── auth.ts           # Custom claims, verificación de roles
├── package.json
├── tsconfig.json
└── .eslintrc.js
```

## Convenciones de命名

| Tipo | Prefijo | Ejemplo |
|------|---------|---------|
| HTTPS Callable (cliente llama) | `verboSustantivo` | `crearPreferenciaPago`, `validarQrAbordaje` |
| HTTPS Público (webhooks) | `servicioWebhook` | `mercadoPagoWebhook` |
| Firestore Trigger | `onColeccionEvento` | `onReservaCreated`, `onSalidaUpdated` |
| Modelos/Interfaces | `PascalCase` + sufijo | `PaymentPreferenceRequest`, `UserCustomClaims` |
| Servicios | `PascalCase` + `Service` | `MercadoPagoService` |
| Utils | `camelCase` | `runTransactionWithRetry`, `setUserRole` |

## Despliegue

```bash
cd functions
npm install
npm run build          # Compila TypeScript a lib/
firebase deploy --only functions
```

## Variables de entorno (Functions config)

```bash
firebase functions:config:set \
  mercadopago.access_token="APP_USR-..." \
  mercadopago.webhook_secret="WH_SEC_..." \
  fcm.server_key="AAAA..." \
  # Opcionales
  app.frontend_url="https://utebus-4435b.web.app"
```

## Seguridad

- **Callable functions**: Validar `request.auth?.uid` y roles via custom claims
- **Webhooks públicos**: Verificar firma HMAC (`mercadopago.ts::verifySignature`)
- **Firestore triggers**: Se ejecutan con privilegios de Admin SDK
- **Reglas Firestore**: Protegen escrituras sensibles (QR secreto, pagos.aprobado)

## Testing

```bash
npm test                 # Jest + firebase-functions-test (emulador)
npm run test:watch       # Watch mode
```

## Logs

```bash
firebase functions:log --only crearPreferenciaPago
# o en consola Firebase > Functions > Logs
```

## Desde Flutter (Cliente)

```dart
// Callable function
final callable = FirebaseFunctions.instance.httpsCallable('crearPreferenciaPago');
final result = await callable.call({'reservaId': id, 'monto': 50.0, 'metodoPago': 'credit_card'});
final initPoint = result.data['initPoint'] as String;
```

## Documentación relacionada

- Arquitectura general: `../docs/arquitectura.md`
- Modelos Firestore: `../docs/arquitectura-y-datos/modelo-firestore.md`
- Reglas seguridad: `../docs/arquitectura-y-datos/reglas-seguridad.md`
- Servicios/integraciones: `../docs/servicios.md`