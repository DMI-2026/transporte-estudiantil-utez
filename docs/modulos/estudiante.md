# Módulo: estudiante (app Flutter)

Features de `lib/src/features/` orientadas al rol estudiante.

## auth (activo)

- Flujo: registro con correo (estudiante con dominio `@utez.edu.mx`; operador con correo libre) crea el documento `usuarios/{uid}` en estado `pendiente`; un administrador lo aprueba tras revisar la credencial.
- Implementado: `presentation/` con login, registro, verificación y `AuthSessionCubit`; `data/` con `FirebaseAuthGateway`, `FirestoreUserRemoteDataSource` y `AuthRepositoryImpl`; `domain/` con `AuthRepository`, `AppUser` y `RegistrationValidator`.
- Router: redirección sin sesión, pendiente, rechazada o aprobada (`app_router.dart`).
- Si falla el guardado del perfil durante el registro, la app cierra la sesión para no dejar una cuenta sin documento.
- Permiso pendiente: cámara o galería para subir la credencial.

## profile (stub)

- Aviso de privacidad, activar o desactivar notificaciones, eliminar cuenta (derechos ARCO).
- El cliente no cambia `rol` ni `estadoVerificacion`.

## home (activo)

- Archivo: `lib/src/features/home/presentation/home_page.dart`.
- Ruta: `AppRoutes.home` (`/inicio`); solo accesible con sesión aprobada.
- Hoy muestra saludo y botón de cerrar sesión. Pendiente: próxima reserva y tiempo estimado de llegada.

## routes_map (stub)

- Lee `rutas`, `paradas` y `salidas` activas; mapa con Google Maps SDK; ubicación bajo demanda para la parada cercana.
- La polilínea viene de Firestore (la calcula Google Routes API al crear la ruta desde el panel admin). Ver [funcionalidades/rutas.md](funcionalidades/rutas.md).

## reservations, boarding, trip, incidents (stub)

Reglas transversales: [funcionalidades/reservas.md](funcionalidades/reservas.md) y [funcionalidades/qr.md](funcionalidades/qr.md).

- trip: mapa con la combi y tiempo estimado a la parada del estudiante.
- incidents: crear y consultar reportes abiertos; foto en Storage; el contacto elegido desde el selector no se guarda.
