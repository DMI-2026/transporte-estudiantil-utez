# Permisos de dispositivo

Esta documentación registra los permisos de dispositivo de la app de Transporte Estudiantil UTEZ: la base obligatoria (P1, P2, P3) y las optativas elegidas (O2, O3, O6, O7).

Sigue las columnas de la sección 4.5 del enunciado. La columna de evidencia se llena con capturas del dispositivo físico en H6.

## Base obligatoria

| **ID** | **Uso en el caso** | **Paquete** | **Servicio** | **Si se niega** |
|----|----|----|----|----|
| P1 Cámara o galería | Foto de credencial (estudiante y operador) y foto opcional del reporte; se reduce con maxWidth: 1280 e imageQuality: 70 antes de subir a Storage. | image_picker | CamaraService | Elegir de galería; en el reporte, enviar sin foto |
| P2 Ubicación en primer plano | Estudiante: al tocar "Parada más cercana" o "Cómo llego". Operador: solo mientras su salida está en curso y la app abierta, con indicador visible. Reporte: al tocar "Agregar ubicación". Si el GPS está apagado, se avisa y se ofrece la alternativa. | geolocator + permission_handler | UbicacionService | Elegir municipio y parada de una lista; en el reporte, escribir la zona |
| P3 Notificaciones | Recordatorio local 15 minutos antes de la salida reservada; se programa al reservar y se cancela al cancelar. Interruptor en Ajustes (notificacionesActivas). | flutter_local_notifications | NotificacionesService | Aviso dentro de la app en Inicio |

## Optativas elegidas

| **ID** | **Pts** | **Uso en el caso** | **Historia** | **Paquete** | **Permisos** |
|----|----|----|----|----|----|
| O2 Escáner QR | 2 | El operador muestra un QR al iniciar el recorrido (generado con qr_flutter, sin permisos); el estudiante lo escanea y su reserva pasa a abordada si el token coincide y no venció. | HU7, HU13 | mobile_scanner | CAMERA · NSCameraUsageDescription |
| O3 Mapa interactivo | 2 | Google Maps con las rutas activas (polilínea), paradas y combi en vivo; al tocar una parada muestra horarios y ETA. | HU3, HU6 | google_maps_flutter | Reutiliza P2 · llave de Maps fuera del repo |
| O6 Push segmentado | 2 | Una Cloud Function detecta cuando una salida pasa a enCurso o cancelada y envía un push solo a quienes tienen reserva en ella y notificaciones activas. P3 sigue siendo local, como exige el enunciado. | HU17 (por agregar) | firebase_messaging + Cloud Functions | POST_NOTIFICATIONS · capability Push en iOS |
| O7 Contacto | 1 | En el reporte de incidente, elegir un contacto con el selector del sistema y abrir WhatsApp, SMS o llamada con wa.me, sms: o tel:. El contacto no se guarda. | HU9, HU14 | Selector del sistema + url_launcher | Sin READ_CONTACTS ni CALL_PHONE |

## Detalle por capacidad (borrador de docs/permisos.md)

Sigue las columnas de la sección 4.5 del enunciado. La columna de evidencia se llena con capturas del dispositivo físico en H6.

| **Capacidad** | **Permiso Android (tipo)** | **Clave iOS** | **Historia** | **Momento de la solicitud** | **Si se niega** | **Dato, finalidad y retención** | **Evidencia (3 estados)** |
|----|----|----|----|----|----|----|----|
| P1 Cámara y galería | CAMERA (ejecución); galería con el selector de fotos, sin permisos de almacenamiento | NSCameraUsageDescription, NSPhotoLibraryUsageDescription | HU2, HU9, HU14 | Al tocar "Tomar foto de credencial" o "Agregar foto" | Elegir de galería; reporte sin foto | Credencial: se borra al resolver. Foto de reporte: 12 meses | Pendiente |
| P2 Ubicación | ACCESS_COARSE_LOCATION (ejecución); ACCESS_FINE_LOCATION solo para el operador | NSLocationWhenInUseUsageDescription | HU3, HU11 | Al tocar "Parada más cercana", "Agregar ubicación" o "Iniciar recorrido" | Elegir municipio, parada o zona | Estudiante: no se guarda. Operador: hasta finalizar la salida. Reporte: 12 meses | Pendiente |
| P3 Notificaciones locales | POST_NOTIFICATIONS (ejecución, Android 13+); sin SCHEDULE_EXACT_ALARM | Autorización en ejecución | HU5 | Al confirmar la primera reserva | Aviso dentro de la app | Preferencia on/off; mientras exista la cuenta | Pendiente |
| O2 QR | CAMERA (ejecución) | NSCameraUsageDescription | HU7, HU13 | Al tocar "Abordar" | El operador marca el abordaje en la lista | El token no se guarda en el dispositivo | Pendiente |
| O3 Mapa | Reutiliza P2; llave de Maps por ambiente | Reutiliza la de P2 | HU6 | Solo si el usuario pide su ubicación en el mapa | Mapa sin punto del usuario | Ninguno adicional | Pendiente |
| O6 Push | POST_NOTIFICATIONS (compartido con P3) | Capability Push Notifications + autorización | HU17 | Al confirmar la primera reserva, junto con P3 | Solo avisos dentro de la app | Token FCM; se borra al cerrar sesión | Pendiente |
| O7 Contacto | Ninguno (selector del sistema) | - | HU9, HU14 | Al tocar "Avisar a un contacto" | Escribir el número a mano | El contacto no se guarda | - |

## Justificación de ACCESS_FINE_LOCATION

El ETA se calcula desde la posición de la combi; con ubicación aproximada (hasta cientos de metros) el error sería de varios minutos. Para el estudiante y para los reportes basta la aproximada.

## Textos de propósito (en español, en Info.plist y en el diálogo previo)

- Cámara: "Usamos la cámara para tomar la foto de tu credencial y verificar tu cuenta, para agregar una foto a un reporte o para escanear el código QR al subir a la combi."

- Galería: "Elige una foto de tu credencial para verificar tu cuenta o una imagen para tu reporte."

- Ubicación: "Usamos tu ubicación solo cuando lo pides: para mostrarte la parada más cercana o, si eres operador, para que los estudiantes vean la combi mientras tu recorrido está activo."

- Notificaciones: "Te avisaremos 15 minutos antes de que salga la combi que reservaste y si tu salida inicia o se cancela. Puedes desactivarlo en Ajustes."

## Evidencia

La columna **Evidencia (3 estados)** se llena con capturas del dispositivo físico en el hito H6. Mientras no se capturen las evidencias, el estado de cada capacidad permanece en `Pendiente`.
