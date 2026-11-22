import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/operator_bottom_nav.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../domain/entities/salida_operador.dart';
import '../../domain/repositories/operator_repository.dart';
import '../widgets/operador_widgets.dart';
import 'recorrido_cubit.dart';

/// Pantalla 05 · Recorrido en curso. Ubicación simulada, sin GPS.
class RecorridoPage extends StatelessWidget {
  const RecorridoPage({super.key, required this.salidaId, this.repository});

  final String salidaId;
  final OperatorRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<OperatorRepository>();
    return BlocProvider(
      create: (_) => RecorridoCubit(repo, salidaId)..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Recorrido en curso')),
        body: BlocBuilder<RecorridoCubit, RecorridoState>(
          builder: (context, state) => UiStateView<SalidaOperador>(
            state: state.salida,
            dataBuilder: (context, s) => _Contenido(salida: s, state: state),
          ),
        ),
        bottomNavigationBar: const OperatorBottomNav(currentIndex: 0),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.salida, required this.state});

  final SalidaOperador salida;
  final RecorridoState state;

  Future<void> _ir(BuildContext context, String ruta) async {
    final cubit = context.read<RecorridoCubit>();
    await context.push(ruta);
    if (context.mounted) await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RecorridoCubit>();
    final theme = Theme.of(context);
    final siguiente = salida.siguienteParada;
    final enCurso = salida.estado == EstadoSalida.enCurso;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (enCurso)
          const AppAlert(
            tone: AppAlertTone.success,
            title: 'Ubicación compartida · Demostración',
          )
        else
          AppAlert(
            tone: AppAlertTone.warning,
            title: salida.estado == EstadoSalida.finalizada
                ? 'Este recorrido ya finalizó'
                : 'Este recorrido aún no inicia',
            message: 'Vuelve a Mis salidas para ver tus recorridos.',
          ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${salida.unidad} · ${salida.id} · ${salida.cupoTotal} asientos',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Abordajes · ${salida.abordados} de ${salida.reservas} reservas',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              ProgresoParadas(salida: salida),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (salida.iniciadaA != null)
          Align(
            alignment: Alignment.centerLeft,
            child: AppStatusChip(
              label: '${salida.rutaCodigo} · Iniciado a las ${salida.iniciadaA}',
              tone: AppStatusTone.success,
            ),
          ),
        if (state.error != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppAlert(
            tone: AppAlertTone.danger,
            title: 'No pudimos registrar la llegada',
            message: state.error,
          ),
        ],
        if (enCurso) ...[
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: siguiente == null
                ? 'Llegaste a ${salida.destino}'
                : state.marcando
                ? 'Registrando…'
                : 'Marcar llegada a ${siguiente.nombre}',
            icon: Icons.place_outlined,
            loading: state.marcando,
            expand: true,
            onPressed: siguiente == null ? null : cubit.marcarLlegada,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ubicación simulada: ${salida.paradaActual.nombre} · ${salida.paradaActual.hora}. '
            'Sin GPS real ni envío de ubicación.',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Reportar incidente',
            variant: AppButtonVariant.secondary,
            expand: true,
            onPressed: () =>
                _ir(context, AppRoutes.operatorNuevoReporteFor(salida.id)),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Finalizar recorrido',
            variant: AppButtonVariant.secondary,
            expand: true,
            onPressed: () =>
                _ir(context, AppRoutes.operatorFinalizarFor(salida.id)),
          ),
        ],
      ],
    );
  }
}
