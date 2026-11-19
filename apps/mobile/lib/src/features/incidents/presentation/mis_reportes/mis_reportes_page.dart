import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatos.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/ui_state.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../domain/entities/reporte.dart';
import '../../domain/repositories/incidents_repository.dart';
import 'mis_reportes_cubit.dart';

/// Pantalla 13 · Mis reportes.
class MisReportesPage extends StatelessWidget {
  const MisReportesPage({super.key, this.repository});

  final IncidentsRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<IncidentsRepository>();
    return BlocProvider(
      create: (_) => MisReportesCubit(repo)..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Mis reportes')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: BlocBuilder<MisReportesCubit, UiState<List<Reporte>>>(
                builder: (context, state) => UiStateView<List<Reporte>>(
                  state: state,
                  emptyTitle: 'Sin reportes',
                  dataBuilder: (context, reportes) => RefreshIndicator(
                    onRefresh: context.read<MisReportesCubit>().load,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: reportes.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) =>
                          _ReporteCard(reporte: reportes[i]),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Builder(
                builder: (context) => AppButton(
                  label: 'Reportar incidente',
                  icon: Icons.add,
                  expand: true,
                  onPressed: () async {
                    final cubit = context.read<MisReportesCubit>();
                    await context.push(AppRoutes.incidents);
                    await cubit.load();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReporteCard extends StatelessWidget {
  const _ReporteCard({required this.reporte});

  final Reporte reporte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tono = switch (reporte.estado) {
      EstadoReporte.abierto => AppStatusTone.warning,
      EstadoReporte.enRevision => AppStatusTone.neutral,
      EstadoReporte.cerrado => AppStatusTone.success,
    };
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${reporte.folio} · ${reporte.tipo}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppStatusChip(label: reporte.estado.texto, tone: tono),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${Formatos.fechaCorta(reporte.fecha)} · ${Formatos.hora(reporte.fecha)} · ${reporte.referencia}',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(reporte.descripcion, style: theme.textTheme.bodyMedium),
          if (reporte.actualizacion != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              reporte.actualizacion!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
