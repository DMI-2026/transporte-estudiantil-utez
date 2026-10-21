import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_page.dart';
import 'app_routes.dart';

/// Navegación base. El redirect por sesión y rol se conecta aquí cuando
/// exista autenticación: sin sesión a inicio de sesión, cuenta pendiente o
/// rechazada a verificación, y cuenta aprobada al inicio de su rol.
class AppRouter {
  AppRouter()
    : router = GoRouter(
        initialLocation: AppRoutes.home,
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'inicio',
            builder: (context, state) => const HomePage(),
          ),
        ],
      );

  final GoRouter router;
}
