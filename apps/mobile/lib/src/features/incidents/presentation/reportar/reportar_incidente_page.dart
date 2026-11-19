import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../../reservations/domain/repositories/reservations_repository.dart';
import '../../domain/entities/reporte.dart';
import '../../domain/repositories/incidents_repository.dart';
import '../../domain/validators/reporte_validator.dart';
import 'reportar_incidente_cubit.dart';

/// Pantalla 12 · Reportar incidente.
class ReportarIncidentePage extends StatelessWidget {
  const ReportarIncidentePage({
    super.key,
    this.referenciaInicial,
    this.incidents,
    this.reservations,
  });

  final String? referenciaInicial;
  final IncidentsRepository? incidents;
  final ReservationsRepository? reservations;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportarIncidenteCubit(
        incidents ?? context.read<IncidentsRepository>(),
        reservations ?? context.read<ReservationsRepository>(),
        referenciaInicial: referenciaInicial,
      )..load(),
      child: BlocListener<ReportarIncidenteCubit, ReportarIncidenteState>(
        listenWhen: (a, b) => a.enviado == null && b.enviado != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reporte ${state.enviado!.folio} enviado.')),
          );
          context.pushReplacement(AppRoutes.myIncidents);
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Reportar incidente')),
          body: BlocBuilder<ReportarIncidenteCubit, ReportarIncidenteState>(
            builder: (context, state) => UiStateView<List<String>>(
              state: state.referencias,
              emptyTitle: 'Sin salidas para reportar',
              dataBuilder: (context, opciones) =>
                  _Formulario(state: state, referencias: opciones),
            ),
          ),
        ),
      ),
    );
  }
}

class _Formulario extends StatelessWidget {
  const _Formulario({required this.state, required this.referencias});

  final ReportarIncidenteState state;
  final List<String> referencias;

  Future<void> _adjuntar(BuildContext context) async {
    final cubit = context.read<ReportarIncidenteCubit>();
    // Explicación previa al permiso (sección 4.2 del enunciado).
    final continuar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.photo_camera_outlined),
        title: const Text('Permiso de cámara'),
        content: const Text(
          'Usamos la cámara solo mientras tomas la foto de la evidencia. '
          'La foto se asocia únicamente a este reporte. Si no lo permites, '
          'puedes enviar el reporte sin evidencia.',
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
    final cubit = context.read<ReportarIncidenteCubit>();
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const AppAlert(
          tone: AppAlertTone.warning,
          title: 'Este canal no atiende emergencias',
          message: 'Si estás en riesgo inmediato, llama al 911.',
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          initialValue: state.tipo,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Tipo de incidente',
            errorText: state.errorTipo,
          ),
          items: [
            for (final t in TiposIncidente.todos)
              DropdownMenuItem(value: t, child: Text(t)),
          ],
          onChanged: state.enviando ? null : cubit.elegirTipo,
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          initialValue: state.referencia,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Salida relacionada',
            errorText: state.errorReferencia,
          ),
          items: [
            for (final r in referencias)
              DropdownMenuItem(value: r, child: Text(r)),
          ],
          onChanged: state.enviando ? null : cubit.elegirReferencia,
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
            hintText: 'Describe lo que pasó con el mayor detalle posible.',
            alignLabelWithHint: true,
            errorText: state.errorDescripcion,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: state.evidencia == null
              ? InkWell(
                  onTap: state.enviando ? null : () => _adjuntar(context),
                  child: Row(
                    children: [
                      const Icon(Icons.add_a_photo_outlined,
                          color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Adjuntar evidencia (opcional)',
                                style: theme.textTheme.titleSmall),
                            Text(
                              'JPG o PNG · máximo 5 MB · Demostración',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
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
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Solo tú y la administración pueden ver tus reportes.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}
