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
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/operator_bottom_nav.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../../incidents/domain/entities/reporte.dart';
import '../../domain/entities/salida_operador.dart';
import '../../domain/repositories/operator_repository.dart';
import 'finalizar_recorrido_cubit.dart';

/// Pantalla 11 · Finalizar recorrido.
class FinalizarRecorridoPage extends StatelessWidget {
  const FinalizarRecorridoPage({
    super.key,
    required this.salidaId,
    this.repository,
  });

  final String salidaId;
  final OperatorRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<OperatorRepository>();
    return BlocProvider(
      create: (_) => FinalizarRecorridoCubit(repo, salidaId)..load(),
      child: BlocListener<FinalizarRecorridoCubit, FinalizarRecorridoState>(
        listenWhen: (a, b) => a.finalizada == null && b.finalizada != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recorrido ${state.finalizada!.id} finalizado.')),
          );
          context.go(AppRoutes.operatorDashboard);
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Finalizar recorrido')),
          body: BlocBuilder<FinalizarRecorridoCubit, FinalizarRecorridoState>(
            builder: (context, state) => UiStateView<ResumenRecorrido>(
              state: state.resumen,
              dataBuilder: (context, r) => _Contenido(resumen: r, state: state),
            ),
          ),
          bottomNavigationBar: const OperatorBottomNav(currentIndex: 0),
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.resumen, required this.state});

  final ResumenRecorrido resumen;
  final FinalizarRecorridoState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FinalizarRecorridoCubit>();
    final theme = Theme.of(context);
    final s = resumen.salida;
    final enCurso = s.estado == EstadoSalida.enCurso;
    final reporte = resumen.reportesAbiertos.isEmpty
        ? null
        : resumen.reportesAbiertos.first;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: AppStatusChip(
            label: s.enUltimaParada
                ? 'Última parada · ${s.destino}'
                : 'Parada actual · ${s.paradaActual.nombre}',
            tone: s.enUltimaParada
                ? AppStatusTone.success
                : AppStatusTone.warning,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Revisa el resumen',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Confirma al llegar y después de que todas las personas hayan descendido.',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInfoRow(
                label: 'Ruta / Unidad',
                value: '${s.rutaCodigo} / ${s.unidad}',
              ),
              AppInfoRow(
                label: 'Salida registrada',
                value:
                    '${Formatos.fechaCorta(s.fecha)} · ${s.iniciadaA ?? s.horaSalida}',
              ),
              AppInfoRow(
                label: 'Llegada registrada',
                value: s.finalizadaA ?? '${s.horaLlegada} · al confirmar',
              ),
              AppInfoRow(
                label: 'Abordajes',
                value: '${s.abordados} de ${s.reservas} reservas',
              ),
              AppInfoRow(
                label: 'Sin abordar',
                value:
                    '${s.porAbordar} ${s.porAbordar == 1 ? 'estudiante' : 'estudiantes'}',
              ),
              AppInfoRow(
                label: 'Reporte propio',
                value: reporte == null
                    ? 'Sin reportes abiertos'
                    : '${reporte.folio} · ${reporte.estado.texto}',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (!s.enUltimaParada && enCurso) ...[
          AppAlert(
            tone: AppAlertTone.warning,
            title: 'Aún no llegas a ${s.destino}',
            message:
                'Finaliza antes solo si administración te lo indicó.',
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AppAlert(
          tone: AppAlertTone.warning,
          title: 'Al confirmar: salida finalizada',
          message: reporte == null
              ? 'Se cierra el abordaje de ${s.id}.'
              : 'Se cierra el abordaje. ${reporte.folio} permanece abierto hasta que administración lo resuelva.',
        ),
        if (state.error != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppAlert(
            tone: AppAlertTone.danger,
            title: 'No pudimos finalizar',
            message: state.error,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: state.finalizando ? 'Finalizando…' : 'Confirmar fin del recorrido',
          icon: Icons.flag_outlined,
          loading: state.finalizando,
          expand: true,
          onPressed: enCurso ? cubit.finalizar : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Volver al recorrido',
          variant: AppButtonVariant.secondary,
          expand: true,
          onPressed: state.finalizando ? null : () => context.pop(),
        ),
      ],
    );
  }
}
