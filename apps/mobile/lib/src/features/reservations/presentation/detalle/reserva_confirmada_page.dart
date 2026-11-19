import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatos.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_info_row.dart';
import '../../../../core/widgets/ui_state.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../domain/entities/reserva.dart';
import '../../domain/repositories/reservations_repository.dart';
import 'reserva_detalle_cubit.dart';

/// Pantalla 16 · Reserva confirmada.
class ReservaConfirmadaPage extends StatelessWidget {
  const ReservaConfirmadaPage({
    super.key,
    required this.folio,
    this.repository,
  });

  final String folio;
  final ReservationsRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<ReservationsRepository>();
    return BlocProvider(
      create: (_) => ReservaDetalleCubit(repo, folio)..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Reserva confirmada')),
        body: BlocBuilder<ReservaDetalleCubit, UiState<Reserva>>(
          builder: (context, state) => UiStateView<Reserva>(
            state: state,
            dataBuilder: (context, r) => _Contenido(reserva: r),
          ),
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.reserva});

  final Reserva reserva;

  @override
  Widget build(BuildContext context) {
    final s = reserva.salida;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        AppAlert(
          tone: AppAlertTone.success,
          title: 'Tu reserva está lista',
          message:
              'Estado: ${reserva.estado.texto.toLowerCase()} · Pago aprobado. Llega a ${reserva.parada.nombre} a las ${reserva.parada.hora}.',
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInfoRow(label: 'Folio de reserva', value: reserva.folio),
              AppInfoRow(
                label: 'Ruta',
                value: '${s.rutaCodigo} · ${s.rutaNombre}',
              ),
              AppInfoRow(
                label: 'Salida',
                value:
                    '${s.id} · ${Formatos.fechaCorta(s.fecha)} · ${s.horaSalida}',
              ),
              AppInfoRow(
                label: 'Parada / Unidad',
                value: '${reserva.parada.nombre} / ${s.unidad}',
              ),
              AppInfoRow(
                label: 'Pago',
                value:
                    '${Formatos.dinero(reserva.pago.monto)} · ${reserva.pago.referencia} · Importe de demostración',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Mostrar QR',
          icon: Icons.qr_code_2,
          expand: true,
          onPressed: () =>
              context.pushReplacement(AppRoutes.boardingFor(reserva.folio)),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Ir a mis reservas',
          variant: AppButtonVariant.secondary,
          expand: true,
          onPressed: () => context.go(AppRoutes.reservations),
        ),
      ],
    );
  }
}
