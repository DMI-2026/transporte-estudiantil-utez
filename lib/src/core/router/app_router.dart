import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login/login_page.dart';
import '../../features/auth/presentation/register/register_page.dart';
import '../../features/auth/presentation/session/auth_session_cubit.dart';
import '../../features/auth/presentation/splash/auth_loading_page.dart';
import '../../features/auth/presentation/verification/verification_page.dart';
import '../../features/home/presentation/home_page.dart';
import 'app_routes.dart';
import 'stream_listenable.dart';

class AppRouter {
  AppRouter(AuthSessionCubit session)
    : router = GoRouter(
        initialLocation: AppRoutes.loading,
        refreshListenable: StreamListenable(session.stream),
        redirect: (context, state) =>
            session.state.redirect(state.matchedLocation),
        routes: [
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
          GoRoute(
            path: AppRoutes.home,
            name: 'inicio',
            builder: (context, state) => const HomePage(),
          ),
        ],
      );

  final GoRouter router;
}

extension AuthSessionRedirect on AuthSessionState {
  String? redirect(String location) {
    const authPaths = {
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.verification,
      AppRoutes.loading,
    };

    switch (status) {
      case AuthSessionStatus.loading:
        return location == AppRoutes.loading ? null : AppRoutes.loading;
      case AuthSessionStatus.unauthenticated:
        if (location == AppRoutes.login || location == AppRoutes.register) {
          return null;
        }
        return AppRoutes.login;
      case AuthSessionStatus.pendingVerification:
      case AuthSessionStatus.rejected:
        return location == AppRoutes.verification
            ? null
            : AppRoutes.verification;
      case AuthSessionStatus.authenticated:
        if (authPaths.contains(location)) {
          return AppRoutes.home;
        }
        return null;
    }
  }
}
