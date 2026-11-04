import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/router/app_router.dart';
import 'package:transporte_estudiantil/src/core/router/app_routes.dart';
import 'package:transporte_estudiantil/src/features/auth/presentation/session/auth_session_cubit.dart';

void main() {
  AuthSessionState sesion(AuthSessionStatus status) =>
      AuthSessionState(status: status);

  group('AuthSessionRedirect', () {
    test('loading manda a /cargando', () {
      final s = sesion(AuthSessionStatus.loading);
      expect(s.redirect(AppRoutes.home), AppRoutes.loading);
      expect(s.redirect(AppRoutes.loading), isNull);
    });

    test('sin sesión solo permite login y registro', () {
      final s = sesion(AuthSessionStatus.unauthenticated);
      expect(s.redirect(AppRoutes.login), isNull);
      expect(s.redirect(AppRoutes.register), isNull);
      expect(s.redirect(AppRoutes.home), AppRoutes.login);
      expect(s.redirect(AppRoutes.verification), AppRoutes.login);
      expect(s.redirect(AppRoutes.loading), AppRoutes.login);
    });

    test('pendiente o rechazada quedan en /verificacion', () {
      for (final st in [
        AuthSessionStatus.pendingVerification,
        AuthSessionStatus.rejected,
      ]) {
        final s = sesion(st);
        expect(s.redirect(AppRoutes.home), AppRoutes.verification);
        expect(s.redirect(AppRoutes.login), AppRoutes.verification);
        expect(s.redirect(AppRoutes.verification), isNull);
      }
    });

    test('autenticado sale de las rutas de auth y navega libre', () {
      final s = sesion(AuthSessionStatus.authenticated);
      expect(s.redirect(AppRoutes.login), AppRoutes.home);
      expect(s.redirect(AppRoutes.register), AppRoutes.home);
      expect(s.redirect(AppRoutes.verification), AppRoutes.home);
      expect(s.redirect(AppRoutes.loading), AppRoutes.home);
      expect(s.redirect(AppRoutes.home), isNull);
      expect(s.redirect('/otra'), isNull);
    });
  });
}
