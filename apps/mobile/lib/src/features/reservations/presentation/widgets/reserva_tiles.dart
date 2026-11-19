import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatos.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_trip_card.dart';
import '../../domain/entities/reserva.dart';
import '../../domain/entities/salida.dart';

AppStatusTone toneDeReserva(EstadoReserva estado) => switch (estado) {
  EstadoReserva.reservada => AppStatusTone.success,
  EstadoReserva.pendientePago => AppStatusTone.warning,
  EstadoReserva.abordada => AppStatusTone.neutral,
  EstadoReserva.cancelada => AppStatusTone.danger,
};

/// "UTEZ / Tarjeta / Reserva" sobre el `AppTripCard` del equipo.
class ReservaCard extends StatelessWidget {
  const ReservaCard({super.key, required this.reserva, this.onTap});

  final Reserva reserva;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = reserva.salida;
    return AppTripCard(
      routeCode: s.rutaCodigo,
      statusLabel: reserva.estado.texto,
      statusTone: toneDeReserva(reserva.estado),
      origin: s.origen,
      destination: s.destino,
      departureTime: s.horaSalida,
      arrivalTime: s.horaLlegada,
      dateLabel: '${Formatos.fechaCorta(s.fecha)} · Folio ${reserva.folio}',
      unitLabel: '${s.unidad} · Parada ${reserva.parada.nombre}',
      trailing: onTap == null
          ? null
          : const Icon(Icons.qr_code_2, color: AppColors.primary),
      onTap: onTap,
    );
  }
}

/// Tarjeta seleccionable de una salida (pantalla 08).
class SalidaCard extends StatelessWidget {
  const SalidaCard({
    super.key,
    required this.salida,
    required this.seleccionada,
    this.onTap,
  });

  final Salida salida;
  final bool seleccionada;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (texto, tono) = salida.llena
        ? ('Sin lugares', AppStatusTone.danger)
        : salida.pocosLugares
        ? ('Pocos lugares', AppStatusTone.warning)
        : ('Programada', AppStatusTone.success);
    return Semantics(
      selected: seleccionada,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: seleccionada ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: AppTripCard(
          routeCode: salida.rutaCodigo,
          statusLabel: texto,
          statusTone: tono,
          origin: salida.origen,
          destination: salida.destino,
          departureTime: salida.horaSalida,
          arrivalTime: salida.horaLlegada,
          dateLabel:
              '${Formatos.fechaCortaAnio(salida.fecha)} · ${salida.unidad} · ${salida.operador}',
          unitLabel:
              '${salida.disponibles} disponibles · ${salida.reservados} de ${salida.cupoTotal} reservados',
          trailing: seleccionada
              ? const Icon(Icons.check_circle, color: AppColors.primary)
              : null,
          onTap: salida.llena ? null : onTap,
        ),
      ),
    );
  }
}

/// Viaje anterior en formato compacto (pantalla 09).
class ViajeAnteriorTile extends StatelessWidget {
  const ViajeAnteriorTile({super.key, required this.reserva});

  final Reserva reserva;

  @override
  Widget build(BuildContext context) {
    final s = reserva.salida;
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s.rutaCodigo} · ${Formatos.fechaCortaAnio(s.fecha)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${s.horaSalida} · ${s.origen} → ${s.destino} · ${s.unidad}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          AppStatusChip(
            label: reserva.estado.texto,
            tone: toneDeReserva(reserva.estado),
          ),
        ],
      ),
    );
  }
}
