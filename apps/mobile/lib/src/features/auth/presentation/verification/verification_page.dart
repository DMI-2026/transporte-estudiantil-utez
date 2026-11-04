import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/mensaje_estado.dart';
import '../session/auth_session_cubit.dart';

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
      appBar: AppBar(title: const Text('Verificación de cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Expanded(
              child: MensajeEstado(
                icono: isRejected
                    ? Icons.block_outlined
                    : Icons.hourglass_empty_outlined,
                titulo: isRejected ? 'Cuenta no aprobada' : 'Cuenta en revisión',
                detalle: isRejected
                    ? 'Tu solicitud fue rechazada. Contacta al administrador del transporte.'
                    : 'Estamos verificando tu credencial. Recibirás acceso cuando un administrador apruebe tu cuenta.',
              ),
            ),
            AppButton(
              label: 'Cerrar sesión',
              variant: AppButtonVariant.secondary,
              expand: true,
              onPressed:
                  onSignOut ?? () => context.read<AuthSessionCubit>().signOut(),
            ),
          ],
        ),
      ),
    );
  }
}
