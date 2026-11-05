# PRD / producto

Cada historia se apoya en un módulo y una fase de [01-alcance.md](01-alcance.md). Las decisiones D-xx viven en ese documento.

## Tabla de decisiones

| # | Decisión | Alternativa descartada | Por qué | Fecha |
|---|----------|------------------------|---------|-------|
| P-01 | La v1 entra con las historias de las fases 1 a 3 (acceso, perfil, mapa, reservas, operación y abordaje); pagos entra en la fase 4 | Pagos desde la fase 1 | Los pagos dependen del plan Blaze y de Cloud Functions (R-01); lo demás funciona sin ellos | 2026-11-04 |
| P-02 | Una reserva puede quedar confirmada sin pago (estado `reservada`) mientras no haya cobro | Exigir pago en toda reserva | Si el cobro se retrasa, la app sigue siendo útil para reservar y abordar | 2026-11-04 |
| P-03 | El estudiante no puede reservar hasta que el administrador verifica su cuenta | Reservar con la cuenta pendiente | El transporte es exclusivo para la comunidad UTEZ (D-08) | 2026-11-04 |
| P-04 | La reserva pagada solo se confirma cuando el servidor recibe el aviso de Mercado Pago | Confirmarla al volver del checkout | El retorno del checkout se puede falsificar (D-05) | 2026-11-04 |
| P-05 | La ubicación del estudiante se pide solo cuando toca "Parada más cercana" y no se guarda | Ubicación continua del estudiante | El estudiante no necesita ser rastreado; solo la combi en recorrido | 2026-11-04 |
| P-06 | Las historias del administrador no entran en este PRD móvil | Pantallas de administrador en la app | La administración va en el panel web (D-07) | 2026-11-04 |

## Historias de usuario

### H-01 · Registro con correo institucional

Como estudiante de la UTEZ quiero registrarme con mi correo institucional para usar el transporte exclusivo.
Módulo del SOW: Acceso · fase 1 · Prioridad: alta.

- Dado que elegí el rol estudiante, cuando escribo un correo que no termina en `@utez.edu.mx` y toco Registrarme, entonces veo el error en el campo y no se crea la cuenta. Prueba: `register_page_test.dart`, «estudiante con correo externo ve el error y no llama al repo».
- Dado que me registré y mi cuenta está pendiente, cuando inicio sesión, entonces veo la pantalla de cuenta en revisión y no puedo reservar. Prueba: `verification_page_test.dart`, «cuenta pendiente muestra mensaje de revisión».
- El registro completo, desde abrir la app hasta la pantalla de verificación, toma menos de 2 minutos.

### H-02 · Baja de cuenta

Como estudiante quiero eliminar mi cuenta y mis datos para ejercer mis derechos ARCO.
Módulo del SOW: Perfil · fase 1 · Prioridad: alta.

- Dado que estoy en Perfil, cuando toco Eliminar cuenta y confirmo, entonces se borran mi perfil y mi foto de credencial y la app me regresa al login.
- Dado que desactivé los avisos en Perfil, cuando se acerca mi salida, entonces no recibo recordatorio local ni aviso push.

### H-03 · Consultar rutas y paradas

Como estudiante quiero ver en el mapa las rutas y sus paradas para saber dónde y a qué hora tomar la combi.
Módulo del SOW: Rutas y mapa · fase 2 · Prioridad: alta.

- Dado que abro el mapa, cuando cargan los datos, entonces veo cada ruta activa con su trazo y sus paradas; al tocar una parada veo sus horarios.
- Dado que negué el permiso de ubicación, cuando toco Parada más cercana, entonces puedo elegir la parada de una lista y la app no vuelve a pedir el permiso en ese momento.

### H-04 · Reservar asiento

Como estudiante verificado quiero reservar un asiento en una salida para asegurar mi lugar en la combi.
Módulo del SOW: Reservas · fase 2 · Prioridad: alta.

- Dado que estoy en el mapa, cuando elijo una salida con cupo y confirmo, entonces la reserva queda hecha en máximo 4 toques y el cupo baja en 1.
- Dado que la salida tiene 0 asientos disponibles, cuando intento reservar, entonces veo «Sin asientos» y no se crea ninguna reserva.
- Dado que tengo una reserva, cuando faltan 15 minutos para la salida, entonces recibo un recordatorio local.

### H-05 · Iniciar recorrido

Como operador quiero iniciar mi salida y transmitir mi ubicación para que los estudiantes sigan la combi.
Módulo del SOW: Operación · fase 3 · Prioridad: alta.

- Dado que tengo una salida asignada, cuando toco Iniciar recorrido, entonces la salida pasa a «en curso» y mi posición se actualiza en el mapa de los estudiantes al menos cada 15 segundos.
- Dado que toco Finalizar recorrido, entonces la salida pasa a «finalizada» y la app deja de enviar mi ubicación.

### H-06 · Abordar con QR

Como estudiante quiero escanear el QR del operador para que mi abordaje quede registrado.
Módulo del SOW: Abordaje · fase 3 · Prioridad: media.

- Dado que tengo reserva en la salida en curso, cuando escaneo un QR válido, entonces en menos de 3 segundos veo «Abordaje confirmado» y mi reserva pasa a abordada.
- Dado que escaneo un QR vencido o de otra salida, entonces veo «QR no válido» y mi reserva no cambia.

### H-07 · Reportar una incidencia

Como estudiante quiero reportar una incidencia con foto opcional para avisar de un problema en el viaje.
Módulo del SOW: Viaje e incidencias · fase 3 · Prioridad: media.

- Dado que negué el permiso de cámara, cuando envío el reporte, entonces se envía sin foto y veo la confirmación.
- Dado que adjunto una foto, cuando la envío, entonces se sube reducida a máximo 1280 px de ancho.

### H-08 · Pagar la reserva

Como estudiante quiero pagar mi reserva con Mercado Pago para confirmar mi asiento cuando la salida tiene costo.
Módulo del SOW: Pagos y avisos · fase 4 · Prioridad: media.

- Dado que pagué y volví a la app, cuando el servidor aún no confirma el pago, entonces mi reserva aparece como «pendiente de pago».
- Dado que el pago fue rechazado, entonces la reserva no se confirma y veo un mensaje para intentar de nuevo.

## Requisitos no funcionales (NFR)

| # | Tipo | Requisito |
|---|------|-----------|
| NFR-01 | Seguridad | La app nunca marca un pago como aprobado ni lee el secreto del QR; las reglas de Firestore rechazan esas escrituras y lecturas desde cualquier cliente |
| NFR-02 | Privacidad | La foto de credencial solo la leen su dueño y el administrador; la ubicación del estudiante y el contacto elegido para una incidencia no se guardan |
| NFR-03 | Permisos | Cada permiso (cámara, ubicación, notificaciones) se pide en el momento de usarlo, con un texto en español que explica para qué; si se niega, la app ofrece una alternativa y sigue funcionando |
| NFR-04 | Errores | Ningún mensaje al usuario muestra detalles técnicos ni trazas; un fallo de red muestra un mensaje con acción para reintentar. Prueba: `login_cubit_test.dart`, «un fallo de red deja mensaje sin stack» |
| NFR-05 | Secretos | Ninguna llave de Mercado Pago, Google Routes ni service account vive en la app ni en el repositorio |
| NFR-06 | Rendimiento | Las fotos se reducen a máximo 1280 px y calidad 70 antes de subir a Storage |

## Fuera de alcance

- Pantallas de administración en la app móvil (D-07, P-06).
- Confirmar un pago desde la app o pagar con un medio distinto de Mercado Pago (D-05, P-04).
- Cuentas para personas sin correo `@utez.edu.mx` (D-08).
- Versión web de la app para estudiantes u operadores (D-02).
- Rastreo de ubicación en segundo plano o rastreo del estudiante (P-05).
