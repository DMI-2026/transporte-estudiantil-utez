import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatos.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/operator_bottom_nav.dart';
import '../../../../core/widgets/ui_state.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../../incidents/domain/entities/reporte.dart';
import '../../domain/repositories/operator_repository.dart';
import 'operador_reportes_cubit.dart';

/// Pantalla 09 · Mis reportes (pestaña Reportes).
class OperadorReportesPage extends StatelessWidget {
  const OperadorReportesPage({super.key, this.repository});

  final OperatorRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<OperatorRepository>();
    return BlocProvider(
      create: (_) => OperadorReportesCubit(repo)..load(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppPageHeader(
                title: 'Mis reportes',
                subtitle:
                    'Reportes que creaste. Los de pasajeros solo los gestiona administración.',
              ),
              Expanded(
                child: BlocBuilder<OperadorReportesCubit, UiState<List<Reporte>>>(
                  builder: (context, state) => UiStateView<List<Reporte>>(
                    state: state,
                    emptyTitle: 'Sin reportes',
                    dataBuilder: (context, reportes) => RefreshIndicator(
                      onRefresh: context.read<OperadorReportesCubit>().load,
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Builder(
                  builder: (context) => AppButton(
                    label: 'Crear reporte',
                    variant: AppButtonVariant.secondary,
                    expand: true,
                    onPressed: () async {
                      final cubit = context.read<OperadorReportesCubit>();
                      await context.push(AppRoutes.operatorNuevoReporte);
                      await cubit.load();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  'Los reportes no detienen automáticamente una salida.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ),
              const OperatorBottomNav(currentIndex: 2),
            ],
          ),
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
                  reporte.folio,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppStatusChip(label: reporte.estado.texto, tone: tono),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            reporte.tipo,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            reporte.referencia,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          Text(
            '${Formatos.fechaCorta(reporte.fecha)} · ${Formatos.hora(reporte.fecha)} · ${reporte.estado.texto}',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
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
