import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/errors/app_failure.dart';
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
import '../data/pase_gateway.dart';

/// Pantalla 10 · Pase de abordaje con QR.
///
/// El payload lo firma Cloud Functions (`obtenerPaseAbordaje`). La app no
/// valida el secreto ni lo escribe en logs de release (D-06).
class QrAbordajePage extends StatelessWidget {
  const QrAbordajePage({
    super.key,
    required this.folio,
    this.repository,
    this.pase,
  });

  final String folio;
  final ReservationsRepository? repository;
  final PaseGateway? pase;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<ReservationsRepository>();
    final gateway = pase ?? context.read<PaseGateway>();
    return BlocProvider(
      create: (_) => ReservaDetalleCubit(repo, folio)..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tu pase de abordaje')),
        body: BlocBuilder<ReservaDetalleCubit, UiState<Reserva>>(
          builder: (context, state) => UiStateView<Reserva>(
            state: state,
            dataBuilder: (context, r) => r.qrValido
                ? _PaseValido(reserva: r, pase: gateway)
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

class _PaseValido extends StatefulWidget {
  const _PaseValido({required this.reserva, required this.pase});

  final Reserva reserva;
  final PaseGateway pase;

  @override
  State<_PaseValido> createState() => _PaseValidoState();
}

class _PaseValidoState extends State<_PaseValido> {
  late final Future<String> _payloadFuture;

  @override
  void initState() {
    super.initState();
    _payloadFuture = widget.pase.obtenerPayload(widget.reserva.folio);
  }

  Future<void> _cancelar(BuildContext context) async {
    final cubit = context.read<ReservaDetalleCubit>();
    await context.push(AppRoutes.cancelarReservaFor(widget.reserva.folio));
    await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final reserva = widget.reserva;
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
              FutureBuilder<String>(
                future: _payloadFuture,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator.adaptive()),
                    );
                  }
                  if (snap.hasError) {
                    final msg = snap.error is AppFailure
                        ? (snap.error! as AppFailure).userMessage
                        : 'No se pudo cargar el pase.';
                    return MensajeEstado(
                      icono: Icons.qr_code_2,
                      titulo: 'Pase no disponible',
                      detalle: msg,
                    );
                  }
                  final payload = snap.data!;
                  if (kDebugMode) {
                    // En debug solo el folio; nunca el secreto completo.
                    debugPrint('Pase listo para folio ${reserva.folio}');
                  }
                  return Column(
                    children: [
                      Semantics(
                        label: 'Código QR de la reserva ${reserva.folio}',
                        image: true,
                        child: QrImageView(
                          data: payload,
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
                        '${reserva.folio} · Pase de abordaje',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  );
                },
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
                value:
                    '${reserva.parada.nombre} · ${reserva.parada.hora} / ${s.unidad}',
              ),
              AppInfoRow(
                label: 'Pago',
                value:
                    '${Formatos.dinero(reserva.pago.monto)} · Un solo abordaje',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const AppAlert(
          title: 'Sube el brillo de tu pantalla',
          message:
              'El operador escanea el código al abordar. Es válido una sola vez.',
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
