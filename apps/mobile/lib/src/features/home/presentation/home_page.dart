import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/student_bottom_nav.dart';
import '../../../core/widgets/ui_state.dart';
import '../../../core/widgets/ui_state_view.dart';
import '../../auth/domain/entities/app_user.dart';
import '../../auth/presentation/session/auth_session_cubit.dart';
import '../../reservations/domain/entities/reserva.dart';
import '../../reservations/domain/repositories/reservations_repository.dart';
import '../../reservations/presentation/widgets/reserva_tiles.dart';
import 'home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.user,
    this.onSignOut,
    this.reservations,
  });

  /// Solo para tests: si se pasan, la página no depende de [AuthSessionCubit].
  final AppUser? user;
  final VoidCallback? onSignOut;
  final ReservationsRepository? reservations;

  @override
  Widget build(BuildContext context) {
    final repo = reservations ?? context.read<ReservationsRepository>();
    return BlocProvider(
      create: (_) => HomeCubit(repo)..load(),
      child: _HomeView(user: user, onSignOut: onSignOut),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({this.user, this.onSignOut});

  final AppUser? user;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final sessionUser = (user != null || onSignOut != null)
        ? user
        : context.watch<AuthSessionCubit>().state.user;
    final theme = Theme.of(context);
    final sessionState = sessionUser == null
        ? const UiEmpty<AppUser>(message: 'No hay sesión activa.')
        : UiData(sessionUser);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'TRANSPORTE ESTUDIANTIL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar sesión',
                    onPressed: onSignOut ??
                        () => context.read<AuthSessionCubit>().signOut(),
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
            ),
            Expanded(
              child: UiStateView<AppUser>(
                state: sessionState,
                emptyTitle: 'Sin sesión',
                dataBuilder: (context, current) {
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      Text(
                        current.displayName == null
                            ? 'Hola'
                            : 'Hola, ${current.displayName}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Reserva tu lugar, sigue la combi y aborda con QR.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Próxima reserva',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      BlocBuilder<HomeCubit, HomeState>(
                        builder: (context, home) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              UiStateView<Reserva>(
                                state: home.proxima,
                                emptyTitle: 'Sin reserva próxima',
                                dataBuilder: (context, reserva) {
                                  return ReservaCard(
                                    reserva: reserva,
                                    onTap: reserva.qrValido
                                        ? () => context.push(
                                              AppRoutes.boardingFor(
                                                reserva.folio,
                                              ),
                                            )
                                        : null,
                                  );
                                },
                              ),
                              if (home.proxima is UiEmpty) ...[
                                const SizedBox(height: AppSpacing.md),
                                AppButton(
                                  label: 'Ver salidas',
                                  onPressed: () =>
                                      context.push(AppRoutes.salidas),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            const StudentBottomNav(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}
