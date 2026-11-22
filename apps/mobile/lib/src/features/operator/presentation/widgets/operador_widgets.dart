import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatos.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_trip_card.dart';
import '../../domain/entities/salida_operador.dart';

AppStatusTone toneDeSalida(EstadoSalida estado) => switch (estado) {
  EstadoSalida.programada => AppStatusTone.success,
  EstadoSalida.enCurso => AppStatusTone.warning,
  EstadoSalida.finalizada => AppStatusTone.neutral,
};

/// "SAL-001 · 26 oct · 06:40 · Combi 01".
String resumenSalida(SalidaOperador s) =>
    '${s.id} · ${Formatos.fechaCorta(s.fecha)} · ${s.horaSalida} · ${s.unidad}';

/// "UI / Card / Salida" para la salida principal del operador.
class SalidaOperadorCard extends StatelessWidget {
  const SalidaOperadorCard({super.key, required this.salida, this.onTap});

  final SalidaOperador salida;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppTripCard(
      routeCode: salida.rutaCodigo,
      statusLabel: salida.estado.texto,
      statusTone: toneDeSalida(salida.estado),
      origin: salida.origen,
      destination: salida.destino,
      departureTime: salida.horaSalida,
      arrivalTime: salida.horaLlegada,
      dateLabel:
          '${salida.id} · ${Formatos.fechaCorta(salida.fecha)} · ${salida.unidad}',
      unitLabel:
          '${salida.reservas} reservas · ${salida.cupoTotal} asientos · ${salida.disponibles} disponibles',
      onTap: onTap,
    );
  }
}

/// Tarjeta compacta de una salida posterior ("Siguiente salida").
class SiguienteSalidaCard extends StatelessWidget {
  const SiguienteSalidaCard({super.key, required this.salida});

  final SalidaOperador salida;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Siguiente salida · ${salida.rutaCodigo} · ${salida.horaSalida}',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${salida.origen} → ${salida.destino}',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${salida.id} · ${salida.unidad} · ${salida.reservas} de ${salida.cupoTotal} reservados',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppStatusChip(
            label: salida.estado.texto,
            tone: toneDeSalida(salida.estado),
          ),
        ],
      ),
    );
  }
}

/// Contador grande de la lista de abordaje (Reservas, Abordaron, Por abordar).
class ContadorCard extends StatelessWidget {
  const ContadorCard({super.key, required this.valor, required this.etiqueta});

  final int valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$valor $etiqueta',
      excludeSemantics: true,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$valor',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              etiqueta,
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progreso por paradas del recorrido (pantalla 05).
class ProgresoParadas extends StatelessWidget {
  const ProgresoParadas({super.key, required this.salida});

  final SalidaOperador salida;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < salida.paradas.length; i++)
          Builder(
            builder: (context) {
              final parada = salida.paradas[i];
              final actual = i == salida.indiceParadaActual;
              final pasada = i < salida.indiceParadaActual;
              final detalle = i == 0
                  ? 'Salida'
                  : actual
                  ? 'Parada actual'
                  : pasada
                  ? 'Llegada registrada'
                  : 'Próxima';
              return Semantics(
                label: '${parada.nombre}, ${parada.hora}, $detalle',
                excludeSemantics: true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        pasada
                            ? Icons.check
                            : actual
                            ? Icons.circle
                            : Icons.circle_outlined,
                        size: actual ? 14 : 18,
                        color: pasada || actual
                            ? AppColors.primary
                            : AppColors.muted,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              actual ? '${parada.nombre} · Actual' : parada.nombre,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: pasada || actual
                                    ? AppColors.primary
                                    : AppColors.ink,
                                fontWeight:
                                    actual ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${parada.hora} · $detalle',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
