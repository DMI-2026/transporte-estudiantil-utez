import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ui_state.dart';
import '../../../core/widgets/ui_state_view.dart';
import '../../auth/domain/entities/app_user.dart';
import '../../auth/presentation/session/auth_session_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.user, this.onSignOut});

  /// Solo para tests: si se pasan, la página no depende de [AuthSessionCubit].
  final AppUser? user;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final sessionUser = (user != null || onSignOut != null)
        ? user
        : context.watch<AuthSessionCubit>().state.user;
    final theme = Theme.of(context);
    final state = sessionUser == null
        ? const UiEmpty<AppUser>(message: 'No hay sesión activa.')
        : UiData(sessionUser);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transporte Estudiantil UTEZ'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed:
                onSignOut ?? () => context.read<AuthSessionCubit>().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: UiStateView<AppUser>(
        state: state,
        emptyTitle: 'Sin sesión',
        dataBuilder: (context, current) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transporte exclusivo estudiantil',
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
          );
        },
      ),
    );
  }
}
