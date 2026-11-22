import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/operator_bottom_nav.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../../incidents/domain/validators/reporte_validator.dart';
import '../../domain/entities/salida_operador.dart';
import '../../domain/repositories/operator_repository.dart';
import '../widgets/operador_widgets.dart';
import 'reportar_operador_cubit.dart';

/// Pantalla 08 · Reportar incidente (operador).
class ReportarOperadorPage extends StatelessWidget {
  const ReportarOperadorPage({super.key, this.salidaId, this.repository});

  final String? salidaId;
  final OperatorRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<OperatorRepository>();
    return BlocProvider(
      create: (_) => ReportarOperadorCubit(repo, salidaId: salidaId)..load(),
      child: BlocListener<ReportarOperadorCubit, ReportarOperadorState>(
        listenWhen: (a, b) => a.enviado == null && b.enviado != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reporte ${state.enviado!.folio} enviado.')),
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.operatorReportes);
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Reportar incidente')),
          body: BlocBuilder<ReportarOperadorCubit, ReportarOperadorState>(
            builder: (context, state) => UiStateView<SalidaOperador>(
              state: state.salida,
              emptyTitle: 'Sin salida activa',
              dataBuilder: (context, s) => _Formulario(salida: s, state: state),
            ),
          ),
          bottomNavigationBar: const OperatorBottomNav(currentIndex: 2),
        ),
      ),
    );
  }
}

class _Formulario extends StatelessWidget {
  const _Formulario({required this.salida, required this.state});

  final SalidaOperador salida;
  final ReportarOperadorState state;

  Future<void> _adjuntar(BuildContext context) async {
    final cubit = context.read<ReportarOperadorCubit>();
    // Explicación previa al permiso (sección 4.2 del enunciado).
    final continuar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.photo_camera_outlined),
        title: const Text('Permiso de cámara'),
        content: const Text(
          'Usamos la cámara solo mientras tomas la foto de la evidencia, con la '
          'unidad detenida. Si no lo permites, puedes enviar el reporte sin foto.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ahora no'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (continuar == true) cubit.adjuntarEvidenciaDemo();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportarOperadorCubit>();
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          resumenSalida(salida),
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          initialValue: state.tipo,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Tipo',
            errorText: state.errorTipo,
          ),
          items: [
            for (final t in TiposIncidenteOperador.todos)
              DropdownMenuItem(value: t, child: Text(t)),
          ],
          onChanged: state.enviando ? null : cubit.elegirTipo,
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          initialValue: state.parada,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Parada relacionada',
            errorText: state.errorParada,
          ),
          items: [
            for (final p in salida.paradas)
              DropdownMenuItem(value: p.nombre, child: Text(p.nombre)),
          ],
          onChanged: state.enviando ? null : cubit.elegirParada,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          enabled: !state.enviando,
          minLines: 4,
          maxLines: 6,
          maxLength: ReporteValidator.maxDescripcion,
          textCapitalization: TextCapitalization.sentences,
          onChanged: cubit.escribirDescripcion,
          decoration: InputDecoration(
            labelText: 'Descripción',
            hintText: 'Qué pasó y dónde está detenida la unidad.',
            alignLabelWithHint: true,
            errorText: state.errorDescripcion,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: state.evidencia == null
              ? InkWell(
                  onTap: state.enviando ? null : () => _adjuntar(context),
                  child: Column(
                    children: [
                      const Icon(Icons.upload_outlined, color: AppColors.primary),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Adjuntar evidencia (opcional)',
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        'JPG o PNG · máximo 5 MB · Demostración',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    const Icon(Icons.image_outlined, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(state.evidencia!)),
                    IconButton(
                      tooltip: 'Quitar evidencia',
                      onPressed: state.enviando ? null : cubit.quitarEvidencia,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        const AppAlert(
          tone: AppAlertTone.warning,
          title: 'Primero, tu seguridad',
          message:
              'Envía el reporte con la unidad detenida. En una emergencia llama al 911.',
        ),
        if (state.error != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppAlert(
            tone: AppAlertTone.danger,
            title: 'No pudimos enviar el reporte',
            message: state.error,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: state.enviando ? 'Enviando…' : 'Enviar reporte',
          loading: state.enviando,
          expand: true,
          onPressed: cubit.enviar,
        ),
      ],
    );
  }
}
