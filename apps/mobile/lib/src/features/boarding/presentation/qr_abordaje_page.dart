import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatos.dart';
import '../../../core/widgets/app_alert.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_info_row.dart';
import '../../../core/widgets/mensaje_estado.dart';
import '../../../core/widgets/ui_state.dart';
import '../../../core/widgets/ui_state_view.dart';
import '../../reservations/domain/entities/reserva.dart';
import '../../reservations/domain/repositories/reservations_repository.dart';
import '../../reservations/presentation/detalle/reserva_detalle_cubit.dart';

/// Pantalla 10 · Pase de abordaje con QR.
///
/// El QR de esta versión es de DEMOSTRACIÓN (folio y salida). El secreto
/// real lo firma la Cloud Function de QR (D-06); la app nunca lo valida.
class QrAbordajePage extends StatelessWidget {
  const QrAbordajePage({super.key, required this.folio, this.repository});

  final String folio;
  final ReservationsRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<ReservationsRepository>();
    return BlocProvider(
      create: (_) => ReservaDetalleCubit(repo, folio)..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tu pase de abordaje')),
        body: BlocBuilder<ReservaDetalleCubit, UiState<Reserva>>(
          builder: (context, state) => UiStateView<Reserva>(
            state: state,
            dataBuilder: (context, r) => r.qrValido
                ? _PaseValido(reserva: r)
                : const MensajeEstado(
                    icono: Icons.qr_code_2,
                    titulo: 'Este QR ya no es válido',
                    detalle: 'La reserva fue cancelada o ya se usó.',
                  ),
          ),
        ),
      ),
    );
  }
}

class _PaseValido extends StatelessWidget {
  const _PaseValido({required this.reserva});

  final Reserva reserva;

  Future<void> _cancelar(BuildContext context) async {
    final cubit = context.read<ReservaDetalleCubit>();
    await context.push(AppRoutes.cancelarReservaFor(reserva.folio));
    await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final s = reserva.salida;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        AppCard(
          child: Column(
            children: [
              Text(
                'Presenta este código al operador',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                label: 'Código QR de la reserva ${reserva.folio}',
                image: true,
                child: QrImageView(
                  data: '${reserva.folio}|${s.id}',
                  size: 220,
                  backgroundColor: AppColors.onPrimary,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.ink,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${reserva.folio} ↔ ${s.id} · QR de demostración',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInfoRow(
                label: 'Ruta',
                value: '${s.rutaCodigo} · ${s.origen} — ${s.destino}',
              ),
              AppInfoRow(
                label: 'Salida',
                value: '${Formatos.fechaCorta(s.fecha)} · ${s.horaSalida}',
              ),
              AppInfoRow(
                label: 'Parada / Unidad',
                value: '${reserva.parada.nombre} · ${reserva.parada.hora} / ${s.unidad}',
              ),
              AppInfoRow(
                label: 'Pago',
                value:
                    '${Formatos.dinero(reserva.pago.monto)} · Tarjeta demo · QR de un solo abordaje',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const AppAlert(
          title: 'Sube el brillo de tu pantalla',
          message: 'El operador escanea el código al abordar. Es válido una sola vez.',
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Ver viaje en curso',
          icon: Icons.directions_bus_outlined,
          expand: true,
          onPressed: () => context.push(AppRoutes.tripFor(reserva.folio)),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Cancelar reserva',
          variant: AppButtonVariant.secondary,
          expand: true,
          onPressed: () => _cancelar(context),
        ),
      ],
    );
  }
}
