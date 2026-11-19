import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_info_row.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/student_bottom_nav.dart';
import '../../../../core/widgets/ui_state.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../domain/repositories/reservations_repository.dart';
import '../widgets/reserva_tiles.dart';
import 'mis_reservas_cubit.dart';

/// Pantalla 09 · Mis reservas (pestaña Reservas).
class MisReservasPage extends StatelessWidget {
  const MisReservasPage({super.key, this.repository});

  final ReservationsRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<ReservationsRepository>();
    return BlocProvider(
      create: (_) => MisReservasCubit(repo)..load(),
      child: const _MisReservasView(),
    );
  }
}

class _MisReservasView extends StatelessWidget {
  const _MisReservasView();

  Future<void> _abrir(BuildContext context, String ruta) async {
    final cubit = context.read<MisReservasCubit>();
    await context.push(ruta);
    await cubit.load(mostrarCarga: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppPageHeader(
              title: 'Mis reservas',
              subtitle: 'Tus próximos viajes y el historial.',
            ),
            Expanded(
              child: BlocBuilder<MisReservasCubit, UiState<MisReservas>>(
                builder: (context, state) {
                  final cubit = context.read<MisReservasCubit>();
                  return UiStateView<MisReservas>(
                    state: state,
                    emptyTitle: 'Aún no tienes un viaje',
                    dataBuilder: (context, data) => RefreshIndicator(
                      onRefresh: () => cubit.load(mostrarCarga: false),
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        children: [
                          AppSectionTitle('Próximas · ${data.proximas.length}'),
                          const SizedBox(height: AppSpacing.sm),
                          if (data.proximas.isEmpty)
                            const Text(
                              'Sin reservas activas. Consulta horarios para elegir tu siguiente salida.',
                            ),
                          for (final r in data.proximas) ...[
                            ReservaCard(
                              reserva: r,
                              onTap: () => _abrir(
                                context,
                                AppRoutes.boardingFor(r.folio),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          AppSectionTitle(
                            'Anteriores · ${data.anteriores.length}',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (data.anteriores.isEmpty)
                            const Text('Aún no tienes viajes anteriores.'),
                          for (final r in data.anteriores) ...[
                            ViajeAnteriorTile(reserva: r),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Builder(
                builder: (context) => AppButton(
                  label: 'Reservar un viaje',
                  icon: Icons.add,
                  expand: true,
                  onPressed: () => _abrir(context, AppRoutes.salidas),
                ),
              ),
            ),
            const StudentBottomNav(currentIndex: 2),
          ],
        ),
      ),
    );
  }
}
