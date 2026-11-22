abstract final class AppRoutes {
  static const login = '/login';
  static const register = '/registro';
  static const verification = '/verificacion';
  static const home = '/inicio';
  static const routes = '/rutas';
  static const loading = '/cargando';
  // Rutas por rol (pendientes de implementar features)
  static const operatorDashboard = '/operador';
  static const adminDashboard = '/admin';

  // Módulo estudiante (reservas, abordaje, viaje, incidentes y perfil)
  static const reservations = '/reservas';
  static const salidas = '/reservas/salidas';
  static const reservaConfirmada = '/reservas/confirmada';
  static const cancelarReserva = '/reservas/cancelar';
  static const boarding = '/abordaje';
  static const trip = '/viaje';
  static const incidents = '/incidencias';
  static const myIncidents = '/incidencias/mis-reportes';
  static const profile = '/perfil';
  static const settings = '/perfil/ajustes';
  static const privacy = '/perfil/aviso-privacidad';

  static String reservaConfirmadaFor(String folio) =>
      '$reservaConfirmada/$folio';
  static String cancelarReservaFor(String folio) => '$cancelarReserva/$folio';
  static String boardingFor(String folio) => '$boarding/$folio';
  static String tripFor(String folio) => '$trip/$folio';
  // Módulo operador (operatorDashboard = Mis salidas)
  static const operatorRecorrido = '/operador/recorrido';
  static const operatorAbordaje = '/operador/abordaje';
  static const operatorReportes = '/operador/reportes';
  static const operatorNuevoReporte = '/operador/reportes/nuevo';
  static const operatorPerfil = '/operador/perfil';

  static String operatorRecorridoFor(String salidaId) =>
      '$operatorRecorrido/$salidaId';
  static String operatorFinalizarFor(String salidaId) =>
      '$operatorRecorrido/$salidaId/finalizar';
  static String operatorListaFor(String salidaId) =>
      '$operatorAbordaje/$salidaId/lista';
  static String operatorQrInvalidoFor(String salidaId, String motivo) => Uri(
    path: '$operatorAbordaje/$salidaId/no-valido',
    queryParameters: {'motivo': motivo},
  ).toString();
  static String operatorNuevoReporteFor(String salidaId) => Uri(
    path: operatorNuevoReporte,
    queryParameters: {'salida': salidaId},
  ).toString();

  static String incidentsFor(String referencia) =>
      Uri(path: incidents, queryParameters: {'referencia': referencia})
          .toString();
}
