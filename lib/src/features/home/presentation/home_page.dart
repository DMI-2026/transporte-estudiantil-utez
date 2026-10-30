import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/ui_state.dart';
import '../../../core/widgets/ui_state_view.dart';
import '../../auth/domain/entities/app_user.dart';
import '../../auth/domain/entities/user_role.dart';
import '../../auth/domain/entities/verification_status.dart';
import '../../auth/presentation/session/auth_session_cubit.dart';
import 'home_cubit.dart';
import 'home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.user, this.onSignOut});

  /// Solo para tests: si se pasan, la página no depende de [HomeCubit].
  final AppUser? user;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Modo test: usa parámetros directos sin Cubit
    if (user != null || onSignOut != null) {
      final state = user == null
          ? const UiEmpty<AppUser>(message: 'No hay sesión activa.')
          : UiData(user!);
      return _HomeView(
        state: state,
        onSignOut: onSignOut ?? () {},
        theme: theme,
      );
    }

    // Modo producción: usa HomeCubit
    return BlocProvider(
      create: (_) => HomeCubit(context.read<AuthSessionCubit>()),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, homeState) {
          return _HomeView(
            state: homeState.toUiState(),
            onSignOut: () => context.read<AuthSessionCubit>().signOut(),
            theme: theme,
          );
        },
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({
    required this.state,
    required this.onSignOut,
    required this.theme,
  });

  final UiState<AppUser> state;
  final VoidCallback onSignOut;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transporte Estudiantil UTEZ'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: UiStateView<AppUser>(
        state: state,
        emptyTitle: 'Sin sesión',
        dataBuilder: (context, current) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        AppStatusChip(
                          label: _roleLabel(current.role),
                          icon: Icons.school_outlined,
                        ),
                        AppStatusChip(
                          label: _statusLabel(current.verificationStatus),
                          tone: _statusTone(current.verificationStatus),
                          icon: Icons.verified_user_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Transporte exclusivo estudiantil',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Reserva tu lugar, sigue la combi y aborda con QR.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                    if (current.displayName != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Hola, ${current.displayName}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _roleLabel(UserRole role) => switch (role) {
  UserRole.estudiante => 'Estudiante',
  UserRole.operador => 'Operador',
  UserRole.administrador => 'Administrador',
};

String _statusLabel(VerificationStatus status) => switch (status) {
  VerificationStatus.aprobada => 'Cuenta aprobada',
  VerificationStatus.pendiente => 'En revisión',
  VerificationStatus.rechazada => 'Rechazada',
};

AppStatusTone _statusTone(VerificationStatus status) => switch (status) {
  VerificationStatus.aprobada => AppStatusTone.success,
  VerificationStatus.pendiente => AppStatusTone.warning,
  VerificationStatus.rechazada => AppStatusTone.danger,
};
