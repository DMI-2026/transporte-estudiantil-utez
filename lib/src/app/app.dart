import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/session/auth_session_cubit.dart';

class TransporteApp extends StatelessWidget {
  const TransporteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = getIt<AppRouter>().router;

    // La sesión vive en get_it (la necesita el router); aquí solo se expone
    // al árbol de widgets para que las pantallas usen context.read.
    return BlocProvider.value(
      value: getIt<AuthSessionCubit>(),
      child: MaterialApp.router(
        title: 'Transporte Estudiantil UTEZ',
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
  }
}
