import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/operator_bottom_nav.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../domain/entities/pasajero.dart';
import '../../domain/repositories/operator_repository.dart';
import '../widgets/operador_widgets.dart';
import 'lista_abordaje_cubit.dart';

/// Pantalla 07 · Lista de abordaje de una salida.
class ListaAbordajePage extends StatelessWidget {
  const ListaAbordajePage({super.key, required this.salidaId, this.repository});

  final String salidaId;
  final OperatorRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<OperatorRepository>();
    return BlocProvider(
      create: (_) => ListaAbordajeCubit(repo, salidaId)..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Lista de abordaje')),
        body: BlocBuilder<ListaAbordajeCubit, ListaAbordajeState>(
          builder: (context, state) => UiStateView<ListaAbordaje>(
            state: state.lista,
            emptyTitle: 'Sin reservas',
            dataBuilder: (context, data) =>
                _Contenido(data: data, filtrados: state.filtrados(data)),
          ),
        ),
        bottomNavigationBar: const OperatorBottomNav(currentIndex: 1),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.data, required this.filtrados});

  final ListaAbordaje data;
  final List<Pasajero> filtrados;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ListaAbordajeCubit>();
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: cubit.load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            resumenSalida(data.salida),
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ContadorCard(
                  valor: data.pasajeros.length,
                  etiqueta: 'Reservas',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ContadorCard(valor: data.abordaron, etiqueta: 'Abordaron'),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ContadorCard(
                  valor: data.porAbordar,
                  etiqueta: 'Por abordar',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            onChanged: cubit.buscar,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Buscar estudiante o folio',
              suffixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (filtrados.isEmpty)
            Text(
              'No encontramos a nadie con ese nombre o folio.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            )
          else
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < filtrados.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    ListTile(
                      title: Text(filtrados[i].nombre),
                      subtitle: Text(
                        '${filtrados[i].folio} · ${filtrados[i].parada}',
                      ),
                      trailing: AppStatusChip(
                        label: filtrados[i].estado.texto,
                        tone: filtrados[i].estado == EstadoAbordaje.abordada
                            ? AppStatusTone.success
                            : AppStatusTone.neutral,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Mostrando ${filtrados.length} de ${data.pasajeros.length} · Solo datos de esta salida',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
