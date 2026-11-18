import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/mensaje_estado.dart';
import '../session/auth_session_cubit.dart';
import '../widgets/auth_screen_footer.dart';
import '../widgets/auth_screen_header.dart';

class VerificationPage extends StatelessWidget {
  const VerificationPage({
    super.key,
    this.rejected,
    this.onSignOut,
  });

  /// Solo para tests: fuerza el estado sin depender de [AuthSessionCubit].
  final bool? rejected;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final isRejected =
        rejected ?? context.watch<AuthSessionCubit>().state.isRejected;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const AuthScreenHeader(
              title: 'Verifica tu cuenta',
              heroHeadline: 'Estamos revisando tu solicitud.',
              trailing: AuthScreenHeaderTrailing(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppAlert(
              tone: isRejected ? AppAlertTone.danger : AppAlertTone.info,
              title: isRejected ? 'Cuenta no aprobada' : 'Cuenta en revisión',
              message: isRejected
                  ? 'Tu solicitud fue rechazada. Contacta al administrador del transporte.'
                  : 'Estamos verificando tu credencial. Recibirás acceso cuando un administrador apruebe tu cuenta.',
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 220,
              child: MensajeEstado(
                icono: isRejected
                    ? Icons.block_outlined
                    : Icons.hourglass_empty_outlined,
                titulo: isRejected ? 'Acceso pendiente' : 'Gracias por registrarte',
                detalle: isRejected
                    ? 'Puedes cerrar sesión e intentar con otra cuenta o contactar soporte.'
                    : 'Te avisaremos cuando tu cuenta quede habilitada para reservar.',
              ),
            ),
            AppButton(
              label: 'Cerrar sesión',
              variant: AppButtonVariant.secondary,
              expand: true,
              onPressed:
                  onSignOut ?? () => context.read<AuthSessionCubit>().signOut(),
            ),
            const SizedBox(height: AppSpacing.xl),
            const AuthScreenFooter(),
          ],
        ),
      ),
    );
  }
}