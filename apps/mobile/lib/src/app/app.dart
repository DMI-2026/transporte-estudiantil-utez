import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/session/auth_session_cubit.dart';

class TransporteApp extends StatelessWidget {
  const TransporteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = getIt<AppRouter>().router;

    // La sesión y el repositorio viven en get_it (el router necesita la
    // sesión); aquí se exponen al árbol para que las pantallas usen context.read.
    return RepositoryProvider<AuthRepository>.value(
      value: getIt<AuthRepository>(),
      child: BlocProvider.value(
        value: getIt<AuthSessionCubit>(),
        child: MaterialApp.router(
          title: 'Transporte Estudiantil UTEZ',
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );
  }
}
