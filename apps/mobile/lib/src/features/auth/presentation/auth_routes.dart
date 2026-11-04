import 'package:go_router/go_router.dart';

import 'login/login_page.dart';
import 'register/register_page.dart';
import 'session/auth_session_cubit.dart';
import 'splash/auth_loading_page.dart';
import 'verification/verification_page.dart';
import '../../../core/router/app_routes.dart';

/// Rutas del feature auth.
/// Se registran en [AppRouter] para evitar god object en el router central.
List<RouteBase> authRoutes(AuthSessionCubit session) => [
      GoRoute(
        path: AppRoutes.loading,
        builder: (context, state) => const AuthLoadingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'registro',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.verification,
        name: 'verificacion',
        builder: (context, state) => const VerificationPage(),
      ),
    ];