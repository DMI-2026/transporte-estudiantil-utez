import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_info_row.dart';
import '../../../../core/widgets/operator_bottom_nav.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../domain/entities/salida_operador.dart';
import '../../domain/repositories/operator_repository.dart';
import '../widgets/operador_widgets.dart';
import 'validar_abordaje_cubit.dart';

/// Pantalla 06 · Validar abordaje (pestaña Abordaje).
///
/// La lectura es SIMULADA: no se usa la cámara. La validación real del QR
/// firmado ocurre en la Cloud Function de QR (D-06), nunca en la app.
class ValidarAbordajePage extends StatelessWidget {
  const ValidarAbordajePage({super.key, this.salidaId, this.repository});

  final String? salidaId;
  final OperatorRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<OperatorRepository>();
    return BlocProvider(
      create: (_) => ValidarAbordajeCubit(repo, salidaId: salidaId)..load(),
      child: BlocListener<ValidarAbordajeCubit, ValidarAbordajeState>(
        listenWhen: (a, b) => b.invalida != null && a.invalida != b.invalida,
        listener: (context, state) => context.push(
          AppRoutes.operatorQrInvalidoFor(
            state.invalida!.salida.id,
            state.invalida!.motivo!,
          ),
        ),
        child: Scaffold(
          appBar: AppBar(title: const Text('Validar abordaje')),
          body: BlocBuilder<ValidarAbordajeCubit, ValidarAbordajeState>(
            builder: (context, state) => UiStateView<SalidaOperador>(
              state: state.salida,
              emptyTitle: 'Sin salida activa',
              dataBuilder: (context, s) => _Contenido(salida: s, state: state),
            ),
          ),
          bottomNavigationBar: const OperatorBottomNav(currentIndex: 1),
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.salida, required this.state});

  final SalidaOperador salida;
  final ValidarAbordajeState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ValidarAbordajeCubit>();
    final theme = Theme.of(context);
    final pasajero = state.ultimaValida?.pasajero;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          resumenSalida(salida),
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          label: 'Lector de QR simulado',
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.qr_code_2, size: 140, color: AppColors.ink),
                    Container(width: 200, height: 2, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  state.leyendo
                      ? 'Leyendo…'
                      : 'Lectura simulada · Sin acceso a cámara',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        if (pasajero != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppAlert(
            tone: AppAlertTone.success,
            title: 'QR válido · Reserva abordada',
            message:
                '${pasajero.folio} corresponde a ${salida.id}; pago aprobado.',
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppInfoRow(label: 'Folio', value: pasajero.folio),
                AppInfoRow(label: 'Estudiante', value: pasajero.nombre),
                AppInfoRow(label: 'Parada', value: pasajero.parada),
                AppInfoRow(
                  label: 'Lista actualizada',
                  value: '${salida.abordados} de ${salida.reservas} abordaron',
                ),
              ],
            ),
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.md),
          AppAlert(
            title: 'Listo para leer',
            message:
                'Abordaron ${salida.abordados} de ${salida.reservas}. Pide a cada estudiante su pase de abordaje.',
          ),
        ],
        if (state.error != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppAlert(
            tone: AppAlertTone.danger,
            title: 'No pudimos leer el QR',
            message: state.error,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: pasajero == null ? 'Leer QR' : 'Leer siguiente QR',
          icon: Icons.qr_code_scanner,
          loading: state.leyendo,
          expand: true,
          onPressed: salida.estado == EstadoSalida.finalizada ? null : cubit.leer,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Ver lista de abordaje',
          variant: AppButtonVariant.secondary,
          expand: true,
          onPressed: () =>
              context.push(AppRoutes.operatorListaFor(salida.id)),
        ),
      ],
    );
  }
}
