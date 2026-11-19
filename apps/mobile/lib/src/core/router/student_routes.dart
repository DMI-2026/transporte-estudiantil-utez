import 'package:go_router/go_router.dart';

import '../../features/boarding/presentation/qr_abordaje_page.dart';
import '../../features/incidents/presentation/mis_reportes/mis_reportes_page.dart';
import '../../features/incidents/presentation/reportar/reportar_incidente_page.dart';
import '../../features/profile/presentation/ajustes/ajustes_page.dart';
import '../../features/profile/presentation/perfil/perfil_page.dart';
import '../../features/profile/presentation/privacidad/aviso_privacidad_page.dart';
import '../../features/reservations/presentation/cancelar/cancelar_reserva_page.dart';
import '../../features/reservations/presentation/detalle/reserva_confirmada_page.dart';
import '../../features/reservations/presentation/mis_reservas/mis_reservas_page.dart';
import '../../features/reservations/presentation/salidas/salidas_page.dart';
import '../../features/trip/presentation/viaje_en_curso_page.dart';
import 'app_routes.dart';

/// Rutas del módulo estudiante. Se agregan a `AppRouter` sin cambiar las
/// rutas existentes; la redirección por sesión sigue en `app_router.dart`.
List<RouteBase> studentRoutes() => [
  GoRoute(
    path: AppRoutes.reservations,
    name: 'reservas',
    builder: (context, state) => const MisReservasPage(),
  ),
  GoRoute(
    path: AppRoutes.salidas,
    name: 'salidas',
    builder: (context, state) => const SalidasPage(),
  ),
  GoRoute(
    path: '${AppRoutes.reservaConfirmada}/:folio',
    name: 'reserva-confirmada',
    builder: (context, state) =>
        ReservaConfirmadaPage(folio: state.pathParameters['folio']!),
  ),
  GoRoute(
    path: '${AppRoutes.cancelarReserva}/:folio',
    name: 'cancelar-reserva',
    builder: (context, state) =>
        CancelarReservaPage(folio: state.pathParameters['folio']!),
  ),
  GoRoute(
    path: '${AppRoutes.boarding}/:folio',
    name: 'abordaje',
    builder: (context, state) =>
        QrAbordajePage(folio: state.pathParameters['folio']!),
  ),
  GoRoute(
    path: '${AppRoutes.trip}/:folio',
    name: 'viaje',
    builder: (context, state) =>
        ViajeEnCursoPage(folio: state.pathParameters['folio']!),
  ),
  GoRoute(
    path: AppRoutes.incidents,
    name: 'incidencias',
    builder: (context, state) => ReportarIncidentePage(
      referenciaInicial: state.uri.queryParameters['referencia'],
    ),
  ),
  GoRoute(
    path: AppRoutes.myIncidents,
    name: 'mis-reportes',
    builder: (context, state) => const MisReportesPage(),
  ),
  GoRoute(
    path: AppRoutes.profile,
    name: 'perfil',
    builder: (context, state) => const PerfilPage(),
  ),
  GoRoute(
    path: AppRoutes.settings,
    name: 'ajustes',
    builder: (context, state) => const AjustesPage(),
  ),
  GoRoute(
    path: AppRoutes.privacy,
    name: 'aviso-privacidad',
    builder: (context, state) => const AvisoPrivacidadPage(),
  ),
];
