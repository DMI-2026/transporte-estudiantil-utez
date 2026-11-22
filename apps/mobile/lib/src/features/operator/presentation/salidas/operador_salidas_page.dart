import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatos.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/operator_bottom_nav.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/session/auth_session_cubit.dart';
import '../../domain/entities/salida_operador.dart';
import '../../domain/repositories/operator_repository.dart';
import '../widgets/operador_widgets.dart';
import 'operador_salidas_cubit.dart';

/// Pantalla 04 · Mis salidas (pestaña Salidas, ruta `/operador`).
class OperadorSalidasPage extends StatelessWidget {
  const OperadorSalidasPage({super.key, this.repository, this.user});

  final OperatorRepository? repository;

  /// Solo para tests: evita depender de [AuthSessionCubit].
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<OperatorRepository>();
    final sesion = user ?? context.watch<AuthSessionCubit>().state.user;
    final nombre = (sesion?.displayName ?? '').trim().split(' ').first;
    return BlocProvider(
      create: (_) => OperadorSalidasCubit(repo)..load(),
      child: _OperadorSalidasView(nombre: nombre),
    );
  }
}

class _OperadorSalidasView extends StatelessWidget {
  const _OperadorSalidasView({required this.nombre});

  final String nombre;

  Future<void> _abrirRecorrido(BuildContext context, String id) async {
    final cubit = context.read<OperadorSalidasCubit>();
    await context.push(AppRoutes.operatorRecorridoFor(id));
    await cubit.load(mostrarCarga: false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OperadorSalidasCubit, OperadorSalidasState>(
      listenWhen: (a, b) => a.iniciada == null && b.iniciada != null,
      listener: (context, state) =>
          _abrirRecorrido(context, state.iniciada!.id),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: nombre.isEmpty ? 'Buen día' : 'Buen día, $nombre',
              ),
              Expanded(
                child: BlocBuilder<OperadorSalidasCubit, OperadorSalidasState>(
                  builder: (context, state) =>
                      UiStateView<List<SalidaOperador>>(
                        state: state.salidas,
                        emptyTitle: 'Sin salidas asignadas',
                        dataBuilder: (context, salidas) => _Contenido(
                          salidas: salidas,
                          state: state,
                          onAbrir: (id) => _abrirRecorrido(context, id),
                        ),
                      ),
                ),
              ),
              const OperatorBottomNav(currentIndex: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.salidas,
    required this.state,
    required this.onAbrir,
  });

  final List<SalidaOperador> salidas;
  final OperadorSalidasState state;
  final ValueChanged<String> onAbrir;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OperadorSalidasCubit>();
    final theme = Theme.of(context);
    final pendientes = [
      for (final s in salidas)
        if (s.estado != EstadoSalida.finalizada) s,
    ];
    final principal = pendientes.isEmpty ? null : pendientes.first;
    final finalizadas = salidas.length - pendientes.length;

    return RefreshIndicator(
      onRefresh: () => cubit.load(mostrarCarga: false),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            '${Formatos.fechaCortaAnio(salidas.first.fecha)} · Aprobada · ${salidas.length} salidas',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          if (principal == null)
            const AppAlert(
              tone: AppAlertTone.success,
              title: 'Terminaste tus salidas de hoy',
              message: 'No tienes más recorridos asignados.',
            )
          else ...[
            SalidaOperadorCard(salida: principal),
            const SizedBox(height: AppSpacing.md),
            if (state.error != null) ...[
              AppAlert(
                tone: AppAlertTone.danger,
                title: 'No pudimos iniciar el recorrido',
                message: state.error,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppButton(
              label: principal.estado == EstadoSalida.enCurso
                  ? 'Continuar recorrido'
                  : state.iniciando
                  ? 'Iniciando…'
                  : 'Iniciar recorrido',
              icon: Icons.directions_bus_outlined,
              loading: state.iniciando,
              expand: true,
              onPressed: principal.estado == EstadoSalida.enCurso
                  ? () => onAbrir(principal.id)
                  : () => cubit.iniciar(principal),
            ),
          ],
          for (final s in pendientes.skip(1)) ...[
            const SizedBox(height: AppSpacing.md),
            SiguienteSalidaCard(salida: s),
          ],
          const SizedBox(height: AppSpacing.md),
          const AppAlert(
            tone: AppAlertTone.success,
            title: 'Cuenta aprobada',
            message:
                'Revisa la unidad y la lista de abordaje antes de iniciar.',
          ),
          if (finalizadas > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$finalizadas ${finalizadas == 1 ? 'salida finalizada' : 'salidas finalizadas'} hoy',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Datos de demostración',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
