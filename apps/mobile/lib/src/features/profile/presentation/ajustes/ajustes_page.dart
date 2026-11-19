import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_info_row.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../domain/entities/perfil_estudiante.dart';
import '../../domain/repositories/profile_repository.dart';
import 'ajustes_cubit.dart';

/// Pantalla 15 · Ajustes: notificaciones, permisos y privacidad (F4).
class AjustesPage extends StatelessWidget {
  const AjustesPage({super.key, this.repository});

  final ProfileRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<ProfileRepository>();
    return BlocProvider(
      create: (_) => AjustesCubit(repo)..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Ajustes')),
        body: BlocBuilder<AjustesCubit, AjustesState>(
          builder: (context, state) => UiStateView<PreferenciasNotificacion>(
            state: state.preferencias,
            dataBuilder: (context, p) => _Contenido(preferencias: p, state: state),
          ),
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.preferencias, required this.state});

  final PreferenciasNotificacion preferencias;
  final AjustesState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AjustesCubit>();
    final theme = Theme.of(context);
    final p = preferencias;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (state.error != null) ...[
          AppAlert(
            tone: AppAlertTone.danger,
            title: 'No pudimos guardar el cambio',
            message: state.error,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        const AppSectionTitle('Notificaciones'),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Recordatorios de salida'),
                subtitle: const Text('Te avisamos 15 minutos antes de tu salida.'),
                value: p.recordatoriosSalida,
                onChanged: (v) =>
                    cubit.cambiar(p.copyWith(recordatoriosSalida: v)),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Estado de mis reportes'),
                subtitle: const Text('Cuando la administración responda.'),
                value: p.estadoReportes,
                onChanged: (v) => cubit.cambiar(p.copyWith(estadoReportes: v)),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Avisos generales'),
                subtitle: const Text('Cambios de horario o del servicio.'),
                value: p.avisosGenerales,
                onChanged: (v) => cubit.cambiar(p.copyWith(avisosGenerales: v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const AppSectionTitle('Permisos del teléfono'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Solo pedimos un permiso cuando vas a usar la función que lo necesita. '
          'Puedes cambiarlos cuando quieras desde los ajustes del sistema.',
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _Permiso(
                icon: Icons.photo_camera_outlined,
                nombre: 'Cámara',
                cuando: 'Al adjuntar la evidencia de un reporte.',
                siNo: 'Puedes enviar el reporte sin foto.',
              ),
              Divider(height: 1),
              _Permiso(
                icon: Icons.notifications_outlined,
                nombre: 'Notificaciones',
                cuando: 'Al activar recordatorios o avisos.',
                siNo: 'Verás tus avisos solo dentro de la app.',
              ),
              Divider(height: 1),
              _Permiso(
                icon: Icons.location_off_outlined,
                nombre: 'Ubicación',
                cuando: 'No se usa en esta versión.',
                siNo: 'El viaje en curso muestra datos ilustrativos.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const AppSectionTitle('Privacidad y datos'),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.privacy_tip_outlined,
                color: AppColors.primary),
            title: const Text('Aviso de privacidad'),
            subtitle: const Text('Qué datos usamos y para qué'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
            onTap: () => context.push(AppRoutes.privacy),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const AppInfoRow(label: 'Idioma', value: 'Español (México)'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Transporte estudiantil · Versión 1.0',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}

class _Permiso extends StatelessWidget {
  const _Permiso({
    required this.icon,
    required this.nombre,
    required this.cuando,
    required this.siNo,
  });

  final IconData icon;
  final String nombre;
  final String cuando;
  final String siNo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(nombre),
      subtitle: Text('$cuando\nSi no lo permites: $siNo'),
      isThreeLine: true,
    );
  }
}
