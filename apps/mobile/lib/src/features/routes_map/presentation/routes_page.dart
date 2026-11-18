import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_alert.dart';
import '../../../core/widgets/student_bottom_nav.dart';
import '../../../core/widgets/ui_state_view.dart';
import '../domain/entities/bus_route.dart';
import '../domain/repositories/routes_repository.dart';
import 'routes_cubit.dart';

class RoutesPage extends StatelessWidget {
  const RoutesPage({super.key, this.repository});

  final RoutesRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<RoutesRepository>();
    return BlocProvider(
      create: (_) => RoutesCubit(repo)..load(),
      child: const _RoutesView(),
    );
  }
}

class _RoutesView extends StatelessWidget {
  const _RoutesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<RoutesCubit, RoutesState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    'Rutas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (state.actionMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: AppAlert(
                      tone: state.actionIsError == true
                          ? AppAlertTone.danger
                          : AppAlertTone.success,
                      title: state.actionIsError == true
                          ? 'No se guardó la ruta'
                          : 'Ruta guardada',
                      message: state.actionMessage!,
                    ),
                  ),
                Expanded(
                  child: UiStateView<List<BusRoute>>(
                    state: state.routes,
                    emptyTitle: 'Sin rutas',
                    dataBuilder: (context, routes) {
                      return ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: routes.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final route = routes[index];
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadii.sm),
                              side: const BorderSide(color: AppColors.outline),
                            ),
                            tileColor: AppColors.onPrimary,
                            title: Text(route.nombre),
                            subtitle: route.descripcion == null
                                ? null
                                : Text(route.descripcion!),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: FilledButton(
                    onPressed: state.creating
                        ? null
                        : () => context.read<RoutesCubit>().createDemoRoute(),
                    child: Text(
                      state.creating ? 'Guardando…' : 'Agregar ruta de prueba',
                    ),
                  ),
                ),
                const StudentBottomNav(currentIndex: 1),
              ],
            );
          },
        ),
      ),
    );
  }
}
