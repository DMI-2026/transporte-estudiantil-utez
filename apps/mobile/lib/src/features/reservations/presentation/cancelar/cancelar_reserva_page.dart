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
import '../../../../core/widgets/ui_state_view.dart';
import '../../domain/entities/reserva.dart';
import '../../domain/repositories/reservations_repository.dart';
import 'cancelar_reserva_cubit.dart';

/// Pantalla 17 · Cancelar reserva.
class CancelarReservaPage extends StatelessWidget {
  const CancelarReservaPage({
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
      create: (_) => CancelarReservaCubit(repo, folio)..load(),
      child: BlocListener<CancelarReservaCubit, CancelarReservaState>(
        listenWhen: (a, b) => a.cancelada == null && b.cancelada != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reserva ${state.cancelada!.folio} cancelada.')),
          );
          context.go(AppRoutes.reservations);
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Cancelar reserva')),
          body: BlocBuilder<CancelarReservaCubit, CancelarReservaState>(
            builder: (context, state) => UiStateView<Reserva>(
              state: state.reserva,
              dataBuilder: (context, r) => _Formulario(reserva: r, state: state),
            ),
          ),
        ),
      ),
    );
  }
}

class _Formulario extends StatelessWidget {
  const _Formulario({required this.reserva, required this.state});

  final Reserva reserva;
  final CancelarReservaState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CancelarReservaCubit>();
    final s = reserva.salida;
    if (!reserva.activa) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: AppAlert(
          tone: AppAlertTone.warning,
          title: 'Esta reserva ya no se puede cancelar',
          message: 'Solo puedes cancelar una reserva activa que no hayas abordado.',
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInfoRow(label: 'Folio', value: reserva.folio),
              AppInfoRow(
                label: 'Salida',
                value:
                    '${s.rutaCodigo} · ${Formatos.fechaCorta(s.fecha)} · ${s.horaSalida} · ${reserva.parada.nombre}',
              ),
              AppInfoRow(
                label: 'Reembolso',
                value:
                    '${Formatos.dinero(reserva.pago.monto)} · Política ilustrativa de esta demostración',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppAlert(
          tone: AppAlertTone.warning,
          title: 'Cancelación antes del límite',
          message:
              'La reserva pasará a cancelada, el QR dejará de ser válido y el cupo volverá a ${s.disponibles + reserva.asientos} de ${s.cupoTotal}.',
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          initialValue: state.motivo,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Motivo'),
          items: [
            for (final m in CancelarReservaCubit.motivos)
              DropdownMenuItem(value: m, child: Text(m)),
          ],
          onChanged: state.enviando ? null : cubit.elegirMotivo,
        ),
        const SizedBox(height: AppSpacing.sm),
        CheckboxListTile(
          value: state.confirmado,
          onChanged: state.enviando
              ? null
              : (v) => cubit.confirmar(v ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Entiendo que el QR dejará de ser válido.'),
        ),
        if (state.error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          AppAlert(
            tone: AppAlertTone.danger,
            title: 'No pudimos cancelar',
            message: state.error,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: state.enviando ? 'Cancelando…' : 'Sí, cancelar reserva',
          variant: AppButtonVariant.danger,
          loading: state.enviando,
          expand: true,
          onPressed: state.puedeCancelar ? cubit.cancelar : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Conservar mi reserva',
          variant: AppButtonVariant.secondary,
          expand: true,
          onPressed: state.enviando ? null : () => context.pop(),
        ),
      ],
    );
  }
}
