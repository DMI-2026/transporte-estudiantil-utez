import 'package:go_router/go_router.dart';

import '../../features/operator/presentation/abordaje/lista_abordaje_page.dart';
import '../../features/operator/presentation/abordaje/qr_no_valido_page.dart';
import '../../features/operator/presentation/abordaje/validar_abordaje_page.dart';
import '../../features/operator/presentation/perfil/operador_perfil_page.dart';
import '../../features/operator/presentation/recorrido/finalizar_recorrido_page.dart';
import '../../features/operator/presentation/recorrido/recorrido_page.dart';
import '../../features/operator/presentation/reportes/operador_reportes_page.dart';
import '../../features/operator/presentation/reportes/reportar_operador_page.dart';
import 'app_routes.dart';

/// Rutas del módulo operador. `/operador` (Mis salidas) sigue en
/// `app_router.dart`; la redirección por rol no cambia.
List<RouteBase> operatorRoutes() => [
  GoRoute(
    path: '${AppRoutes.operatorRecorrido}/:salidaId',
    name: 'operador-recorrido',
    builder: (context, state) =>
        RecorridoPage(salidaId: state.pathParameters['salidaId']!),
  ),
  GoRoute(
    path: '${AppRoutes.operatorRecorrido}/:salidaId/finalizar',
    name: 'operador-finalizar',
    builder: (context, state) =>
        FinalizarRecorridoPage(salidaId: state.pathParameters['salidaId']!),
  ),
  GoRoute(
    path: AppRoutes.operatorAbordaje,
    name: 'operador-abordaje',
    builder: (context, state) => const ValidarAbordajePage(),
  ),
  GoRoute(
    path: '${AppRoutes.operatorAbordaje}/:salidaId/lista',
    name: 'operador-lista',
    builder: (context, state) =>
        ListaAbordajePage(salidaId: state.pathParameters['salidaId']!),
  ),
  GoRoute(
    path: '${AppRoutes.operatorAbordaje}/:salidaId/no-valido',
    name: 'operador-qr-no-valido',
    builder: (context, state) => QrNoValidoPage(
      salidaId: state.pathParameters['salidaId']!,
      motivo:
          state.uri.queryParameters['motivo'] ??
          'La reserva no corresponde a esta salida.',
    ),
  ),
  GoRoute(
    path: AppRoutes.operatorReportes,
    name: 'operador-reportes',
    builder: (context, state) => const OperadorReportesPage(),
  ),
  GoRoute(
    path: AppRoutes.operatorNuevoReporte,
    name: 'operador-nuevo-reporte',
    builder: (context, state) =>
        ReportarOperadorPage(salidaId: state.uri.queryParameters['salida']),
  ),
  GoRoute(
    path: AppRoutes.operatorPerfil,
    name: 'operador-perfil',
    builder: (context, state) => const OperadorPerfilPage(),
  ),
];
