import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_card.dart';
import 'app_status_chip.dart';

/// Tarjeta de salida o reserva con ruta, horario y estado.
class AppTripCard extends StatelessWidget {
  const AppTripCard({
    super.key,
    required this.routeCode,
    required this.statusLabel,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    this.statusTone = AppStatusTone.success,
    this.dateLabel,
    this.unitLabel,
    this.trailing,
    this.onTap,
  });

  final String routeCode;
  final String statusLabel;
  final String origin;
  final String destination;
  final String departureTime;
  final String arrivalTime;
  final AppStatusTone statusTone;
  final String? dateLabel;
  final String? unitLabel;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final footer = [dateLabel, unitLabel].whereType<String>().join(' · ');

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppStatusChip(
                label: '$routeCode · $statusLabel',
                tone: statusTone,
              ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$origin — $destination',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$departureTime  →  $arrivalTime',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Stop(label: 'Origen', value: origin),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Stop(
                  label: 'Destino',
                  value: '$destination · llegada estimada',
                  alignEnd: true,
                ),
              ),
            ],
          ),
          if (footer.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              footer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          value,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: theme.textTheme.labelSmall?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}
