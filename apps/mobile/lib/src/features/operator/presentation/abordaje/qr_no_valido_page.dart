import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_info_row.dart';
import '../../../../core/widgets/operator_bottom_nav.dart';

/// Pantalla 12 · No se pudo validar el QR.
class QrNoValidoPage extends StatelessWidget {
  const QrNoValidoPage({super.key, required this.salidaId, required this.motivo});

  final String salidaId;
  final String motivo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('No se pudo validar')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Icon(Icons.qr_code_scanner, size: 56, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Este QR no es válido',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            motivo,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          AppAlert(
            tone: AppAlertTone.danger,
            title: 'No se registró un nuevo abordaje',
            message:
                'Verifica que la reserva esté reservada, pertenezca a $salidaId y no se haya utilizado.',
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppInfoRow(label: 'Salida activa', value: salidaId),
                AppInfoRow(
                  label: 'Lectura',
                  value: 'Simulada · Sin acceso a cámara',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Intentar otra lectura',
            icon: Icons.refresh,
            expand: true,
            onPressed: () => context.pop(),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Buscar en lista de abordaje',
            variant: AppButtonVariant.secondary,
            expand: true,
            onPressed: () =>
                context.pushReplacement(AppRoutes.operatorListaFor(salidaId)),
          ),
        ],
      ),
      bottomNavigationBar: const OperatorBottomNav(currentIndex: 1),
    );
  }
}
