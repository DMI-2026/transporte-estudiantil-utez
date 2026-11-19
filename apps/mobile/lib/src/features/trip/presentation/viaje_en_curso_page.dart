import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_alert.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/ui_state.dart';
import '../../../core/widgets/ui_state_view.dart';
import '../domain/entities/viaje_en_curso.dart';
import '../domain/repositories/trip_repository.dart';
import 'viaje_cubit.dart';

/// Pantalla 11 · Viaje en curso. Ubicación y ETA ilustrativas (sin GPS).
class ViajeEnCursoPage extends StatelessWidget {
  const ViajeEnCursoPage({super.key, required this.folio, this.repository});

  final String folio;
  final TripRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<TripRepository>();
    return BlocProvider(
      create: (_) => ViajeCubit(repo, folio)..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tu viaje en curso')),
        body: BlocBuilder<ViajeCubit, UiState<ViajeEnCurso>>(
          builder: (context, state) => UiStateView<ViajeEnCurso>(
            state: state,
            dataBuilder: (context, v) => _Contenido(viaje: v),
          ),
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.viaje});

  final ViajeEnCurso viaje;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = viaje.reserva.salida;
    return RefreshIndicator(
      onRefresh: context.read<ViajeCubit>().load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const AppAlert(
            tone: AppAlertTone.warning,
            title: 'Datos de demostración',
            message: 'Ubicación y ETA de demostración; sin GPS real.',
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppStatusChip(
                  label: 'En curso · ${s.rutaCodigo}',
                  tone: AppStatusTone.success,
                  icon: Icons.directions_bus,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${s.unidad} en ${viaje.paradaActual.nombre}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Llegada estimada a ${s.destino} en ${viaje.minutosParaLlegar} min · Actualizado ${viaje.actualizadoA}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < viaje.paradas.length; i++)
                  _ParadaFila(
                    nombre: viaje.paradas[i].nombre,
                    hora: viaje.paradas[i].hora,
                    estado: i < viaje.indiceParadaActual
                        ? _Progreso.pasada
                        : i == viaje.indiceParadaActual
                        ? _Progreso.actual
                        : _Progreso.siguiente,
                    esTuParada:
                        viaje.paradas[i].nombre == viaje.reserva.parada.nombre,
                    ultima: i == viaje.paradas.length - 1,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Reportar un incidente',
            icon: Icons.report_outlined,
            variant: AppButtonVariant.secondary,
            expand: true,
            onPressed: () => context.push(
              AppRoutes.incidentsFor('${s.id} · ${s.unidad}'),
            ),
          ),
        ],
      ),
    );
  }
}

enum _Progreso { pasada, actual, siguiente }

class _ParadaFila extends StatelessWidget {
  const _ParadaFila({
    required this.nombre,
    required this.hora,
    required this.estado,
    required this.esTuParada,
    required this.ultima,
  });

  final String nombre;
  final String hora;
  final _Progreso estado;
  final bool esTuParada;
  final bool ultima;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = estado == _Progreso.siguiente
        ? AppColors.outline
        : AppColors.primary;
    final detalle = switch (estado) {
      _Progreso.pasada => 'Pasó',
      _Progreso.actual => 'Unidad aquí',
      _Progreso.siguiente => 'Próxima',
    };
    return Semantics(
      label: '$nombre, $hora, $detalle${esTuParada ? ', tu parada' : ''}',
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: estado == _Progreso.actual
                          ? AppColors.primary
                          : AppColors.onPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 3),
                    ),
                  ),
                  if (!ultima)
                    Expanded(child: Container(width: 2, color: color)),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.ink,
                        fontWeight: estado == _Progreso.actual
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$hora · $detalle${esTuParada ? ' · Tu parada' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
