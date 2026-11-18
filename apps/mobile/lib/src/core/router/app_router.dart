import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/auth_routes.dart';
import '../../features/auth/presentation/session/auth_session_cubit.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/routes_map/presentation/routes_page.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import 'app_routes.dart';
import 'stream_listenable.dart';

class AppRouter {
  AppRouter(AuthSessionCubit session)
    : router = GoRouter(
        initialLocation: AppRoutes.loading,
        refreshListenable: StreamListenable(session.stream),
        redirect: (context, state) =>
            session.state.redirectWithRole(state.matchedLocation),
        routes: [
          ...authRoutes(session),
          GoRoute(
            path: AppRoutes.home,
            name: 'inicio',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.routes,
            name: 'rutas',
            builder: (context, state) => const RoutesPage(),
          ),
          // Rutas por rol (placeholders hasta que existan features)
          GoRoute(
            path: AppRoutes.operatorDashboard,
            name: 'operador',
            builder: (context, state) => const _PlaceholderPage(title: 'Dashboard Operador'),
          ),
          GoRoute(
            path: AppRoutes.adminDashboard,
            name: 'admin',
            builder: (context, state) => const _PlaceholderPage(title: 'Panel Admin'),
          ),
        ],
      );

  final GoRouter router;
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$title — En construcción'),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Ver rutas',
              expand: true,
              onPressed: () => context.push(AppRoutes.routes),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension con redirección por estado de auth + rol.
/// Mantenida en core/router para que los tests existentes sigan funcionando.
extension AuthSessionRedirect on AuthSessionState {
  String? redirect(String location) => redirectWithRole(location);

  String? redirectWithRole(String location) {
    const authPaths = {
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.verification,
      AppRoutes.loading,
    };

    // 1. Redirección por estado de autenticación
    String? authRedirect;
    switch (status) {
      case AuthSessionStatus.loading:
        authRedirect = location == AppRoutes.loading ? null : AppRoutes.loading;
        break;
      case AuthSessionStatus.unauthenticated:
        authRedirect = (location == AppRoutes.login || location == AppRoutes.register)
            ? null
            : AppRoutes.login;
        break;
      case AuthSessionStatus.pendingVerification:
      case AuthSessionStatus.rejected:
        authRedirect = location == AppRoutes.verification ? null : AppRoutes.verification;
        break;
      case AuthSessionStatus.authenticated:
        authRedirect = authPaths.contains(location) ? AppRoutes.home : null;
        break;
    }
    if (authRedirect != null) return authRedirect;

    // 2. Redirección por rol (solo si autenticado)
    if (status == AuthSessionStatus.authenticated) {
      final user = this.user;
      if (user != null) {
        // Operador va a su dashboard en lugar de /inicio
        if (user.role == UserRole.operador && location == AppRoutes.home) {
          return AppRoutes.operatorDashboard;
        }
        // Admin va a panel web (externo), pero si accede a app móvil:
        if (user.role == UserRole.administrador && location == AppRoutes.home) {
          return AppRoutes.adminDashboard;
        }
      }
    }

    return null;
  }
}
