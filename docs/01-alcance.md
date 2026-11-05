# SOW / alcance

## Objetivo

Que los estudiantes de la UTEZ reserven un asiento en la combi del transporte exclusivo, la sigan en el mapa y aborden con un código QR desde el celular, y que el operador gestione su salida y la lista de abordaje desde la misma app.

## Tabla de decisiones

| # | Decisión | Alternativa descartada | Por qué | Fecha |
|---|----------|------------------------|---------|-------|
| D-01 | Metodología Scrum con sprints de 1 semana (de jueves a jueves) y revisión del incremento en la clase de cada semana | Kanban sin cadencia fija | El curso pide una entrega cada semana; el sprint coincide con la clase y cada integrante muestra su avance | 2026-11-04 |
| D-02 | Una sola app Flutter para estudiante y operador; el rol del perfil decide qué pantallas se ven | Dos apps separadas, una por rol | Un solo código, un solo login y el router ya redirige por rol y estado de verificación | 2026-10-26 |
| D-03 | Backend en Firebase (Auth, Firestore, Storage) más Cloud Functions; sin API propia | API REST propia con Node y Express | Un solo backend en la nube; las reglas de Firestore protegen los datos por rol y Functions resuelve lo que el cliente no debe hacer (pagos, QR, push). Ver C-07 | 2026-10-26 |
| D-04 | Servicio en la nube: Firebase (proyecto `utebus-4435b`). API de terceros: Google Maps SDK en la app y Google Routes API llamada solo desde el servidor o el panel | Mapa propio con OpenStreetMap y llamar a Routes desde la app | Maps resuelve el mapa interactivo; la llave de Routes no viaja en el cliente y la polilínea se calcula una vez y se guarda en Firestore | 2026-10-26 |
| D-05 | Pagos con Mercado Pago Checkout Pro; solo el webhook en Cloud Functions marca un pago como aprobado | Confirmar el pago en la app al volver del checkout | El retorno del checkout se puede falsificar; el dinero solo se confirma del lado del servidor | 2026-10-26 |
| D-06 | Abordaje con QR cuyo secreto vive en `salidas/{salidaId}/privado/qr` y lo valida una Cloud Function | Validar el QR en el celular del estudiante | Si el cliente conoce el secreto, cualquiera puede generar un QR válido | 2026-10-26 |
| D-07 | La administración (verificar cuentas, catálogo de rutas, salidas) va en un panel web aparte (`admin-web/`) | Pantallas de administrador dentro de la app móvil | El administrador trabaja en computadora y la app móvil se mantiene pequeña | 2026-10-26 |
| D-08 | Registro de estudiantes solo con correo `@utez.edu.mx` y cuenta verificada por el administrador antes de reservar | Registro abierto con cualquier correo | El transporte es exclusivo para la comunidad UTEZ | 2026-10-26 |

## Módulos y fases

| Fase | Semanas | Módulo | Qué puede hacer la persona al terminar la fase |
|------|---------|--------|------------------------------------------------|
| 1 | 9 a 11 | Acceso | Registrarse, iniciar sesión, esperar la verificación y cerrar sesión (hecho) |
| 1 | 9 a 11 | Perfil | Ver y editar su perfil, activar o desactivar avisos y eliminar su cuenta (derechos ARCO) |
| 2 | 11 a 12 | Rutas y mapa | Consultar rutas, paradas y horarios en el mapa y encontrar la parada más cercana |
| 2 | 12 a 13 | Reservas | Reservar un asiento en una salida con cupo y recibir un recordatorio 15 minutos antes |
| 3 | 12 a 13 | Operación | El operador ve sus salidas, inicia y termina el recorrido y transmite su ubicación |
| 3 | 13 | Abordaje | El estudiante escanea el QR del operador y su reserva pasa a abordada |
| 3 | 13 | Viaje e incidencias | Seguir la combi en vivo con tiempo estimado de llegada y reportar una incidencia |
| 4 | 14 a 15 | Pagos y avisos | Pagar la reserva con Mercado Pago y recibir avisos push cuando su salida inicia o se cancela |
| 4 | 14 a 15 | Administración | El administrador verifica cuentas y mantiene rutas, paradas y salidas desde el panel web |

## Plan temporal

| Fecha | Semana | Hito | Responsable |
|-------|--------|------|-------------|
| 2026-10-29 | 9 | Monorepo con `apps/mobile`, `apps/firebase`, AGENTS.md y documentos SOW, PRD y CONVENCIONES | Nadia Salinas |
| 2026-11-05 | 10 | Backend arrancando con prueba: Cloud Functions compilan y las pruebas de reglas pasan en el emulador | Alison Martinez |
| 2026-11-12 | 11 | Demostración de la unidad II: acceso y perfil con baja de cuenta, con el enlace del repositorio | Hanna Pérez |
| 2026-11-19 | 12 | Mapa con rutas, paradas y parada más cercana | Juan Manuel Chavez |
| 2026-11-26 | 13 | Reservas con control de cupo, abordaje con QR y seguimiento del viaje | David Rojas |
| 2026-12-10 | 15 | Pagos con Mercado Pago, avisos push y panel web de verificación; entrega final | Jesús Juarez |

## Riesgos

| # | Riesgo | Qué haremos antes de que pase | Responsable |
|---|--------|-------------------------------|-------------|
| R-01 | No se activa el plan Blaze de Firebase y no hay Cloud Functions, Storage ni Maps en producción | Activar Blaze con alerta de presupuesto en la semana 10; mientras tanto, probar Functions en el emulador y dejar las reservas en modo gratuito (estado `reservada`) | Jesús Juarez |
| R-02 | Google Maps o Routes no responde o se agota la cuota | La polilínea se guarda en Firestore y no se recalcula en cada consulta; si el mapa falla, la app muestra la lista de paradas con horarios | Juan Manuel Chavez |
| R-03 | Dos estudiantes reservan el último asiento al mismo tiempo y se sobrevende la salida | Reserva en una transacción que baja `asientosDisponibles`; id `{salidaId}_{uid}` exigido por las reglas y prueba de reglas que lo cubre | Nadia Salinas |
| R-04 | Se sube un secreto al repositorio (llave de Mercado Pago, service account) | `.gitignore` con llaves de servicio, revisión con `verify-activity.ps1` en cada PR y secretos solo en el entorno de Cloud Functions | Alison Martinez |
| R-05 | El operador pierde señal de GPS o niega el permiso de ubicación | El estudiante ve la última posición con su hora y el horario programado; el operador recibe un aviso para reactivar la ubicación | David Rojas |
| R-06 | Se filtran datos personales de la credencial del estudiante | Reglas de Storage: la credencial solo la leen el dueño y el administrador; la baja de cuenta borra perfil y credencial | Hanna Pérez |

## Criterios de aceptación de alto nivel

1. Un estudiante con correo `@utez.edu.mx` se registra y llega a la pantalla de verificación en menos de 2 minutos.
2. Desde el mapa, un estudiante verificado reserva un asiento en máximo 4 toques, y una salida nunca queda con menos de 0 asientos disponibles.
3. La posición de la combi en el mapa del estudiante se actualiza al menos cada 15 segundos mientras la salida está en curso.
4. El abordaje con QR responde válido o inválido en menos de 3 segundos con conexión.
5. El recordatorio local llega 15 minutos antes de la salida reservada.
6. `scripts/check.sh` pasa con al menos 10 pruebas unitarias, 5 de widget y 1 de integración.

## Fuera de alcance

- API REST propia: el backend es Firebase con Cloud Functions (D-03).
- Pantallas de administración dentro de la app móvil: van en el panel web (D-07).
- Confirmar un pago desde la app o pagar con otro medio que no sea Mercado Pago (D-05).
- Cuentas para personas sin correo `@utez.edu.mx` (D-08).
- Versión web de la app para estudiantes u operadores (D-02).
- Rastreo de ubicación en segundo plano: el operador solo transmite con la app abierta y la salida en curso.

## Documentos del proyecto

| Documento | ¿Lo necesitamos? | Por qué | Cuándo se escribiría |
|-----------|------------------|---------|----------------------|
| [01 Alcance](01-alcance.md) | Sí | Obligatorio; los demás documentos se apoyan en sus decisiones y fases | Escrito |
| [02 PRD](02-prd.md) | Sí | Obligatorio; cada historia se apoya en un módulo de este SOW | Escrito |
| [03 Integraciones](03-integraciones.md) | Sí | Usamos 3 APIs externas (Google Maps, Google Routes y Mercado Pago) y 5 servicios de Firebase (Auth, Firestore, Storage, Functions y Cloud Messaging) | Escrito |
| [04 Arquitectura](04-arquitectura.md) | Sí | Hay 4 componentes (app Flutter, Firebase, Cloud Functions y panel web) y 3 roles que se aíslan con las reglas de Firestore | Escrito |
| [05 Datos](05-datos.md) | Sí | Guardamos 7 colecciones relacionadas: usuarios, rutas, paradas, salidas, reservas, pagos y reportes | Escrito |
| [06 Convenciones](06-convenciones.md) | Sí | Obligatorio; reglas de Git, pruebas y organización que comparten las 6 personas del equipo | Escrito |
