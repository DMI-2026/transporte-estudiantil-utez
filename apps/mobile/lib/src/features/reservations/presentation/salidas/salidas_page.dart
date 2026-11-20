import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatos.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_info_row.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../data/datasources/pagos_gateway.dart';
import '../../domain/entities/salida.dart';
import '../../domain/repositories/reservations_repository.dart';
import '../widgets/reserva_tiles.dart';
import 'salidas_cubit.dart';

/// Pantalla 08 · Elegir salida y reservar.
class SalidasPage extends StatelessWidget {
  const SalidasPage({
    super.key,
    this.repository,
    this.pagos,
    this.abrirCheckout = true,
  });

  final ReservationsRepository? repository;
  final PagosGateway? pagos;
  final bool abrirCheckout;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<ReservationsRepository>();
    final gateway = pagos ?? context.read<PagosGateway>();
    return BlocProvider(
      create: (_) => SalidasCubit(
        repo,
        pagos: gateway,
        abrirCheckout: abrirCheckout,
      )..load(),
      child: const _SalidasView(),
    );
  }
}

class _SalidasView extends StatelessWidget {
  const _SalidasView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SalidasCubit, SalidasState>(
      listenWhen: (a, b) => a.reservaCreada == null && b.reservaCreada != null,
      listener: (context, state) => context.pushReplacement(
        AppRoutes.reservaConfirmadaFor(state.reservaCreada!.folio),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Elige tu salida')),
        body: BlocBuilder<SalidasCubit, SalidasState>(
          builder: (context, state) {
            final cubit = context.read<SalidasCubit>();
            return UiStateView<List<Salida>>(
              state: state.salidas,
              emptyTitle: 'Sin salidas',
              dataBuilder: (context, salidas) => ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  const AppSectionTitle('Rutas disponibles'),
                  const SizedBox(height: AppSpacing.sm),
                  for (final s in salidas) ...[
                    SalidaCard(
                      salida: s,
                      seleccionada: state.seleccionada?.id == s.id,
                      onTap: () => cubit.seleccionar(s),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  if (state.seleccionada != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _Resumen(state: state),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.state});

  final SalidasState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SalidasCubit>();
    final salida = state.seleccionada!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionTitle('Parada de abordaje'),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          key: ValueKey(salida.id),
          initialValue: state.parada,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Parada'),
          items: [
            for (final p in salida.paradas.take(salida.paradas.length - 1))
              DropdownMenuItem(
                value: p.nombre,
                child: Text('${p.nombre} · ${p.hora}'),
              ),
          ],
          onChanged: state.reservando ? null : cubit.elegirParada,
        ),
        const SizedBox(height: AppSpacing.md),
        AppInfoRow(
          label: 'Importe de demostración',
          value: '${Formatos.dinero(salida.precio)} · No es tarifa oficial',
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppAlert(
          title: 'Pago de demostración',
          message:
              'La reserva queda pendiente de pago. Se abre Mercado Pago; la aprobación la confirma el servidor (webhook), no la app.',
        ),
        if (state.error != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppAlert(
            tone: AppAlertTone.danger,
            title: 'No pudimos reservar',
            message: state.error,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: state.reservando ? 'Reservando…' : 'Reservar y continuar al pago',
          loading: state.reservando,
          expand: true,
          onPressed: state.puedeReservar ? cubit.reservar : null,
        ),
      ],
    );
  }
}
