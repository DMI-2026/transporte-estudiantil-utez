import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatos.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_info_row.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/student_bottom_nav.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/session/auth_session_cubit.dart';
import '../../domain/entities/perfil_estudiante.dart';
import '../../domain/repositories/profile_repository.dart';
import 'editar_contacto_sheet.dart';
import 'perfil_cubit.dart';

/// Pantalla 14 · Mi perfil (pestaña Perfil).
class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key, this.repository, this.user, this.onSignOut});

  final ProfileRepository? repository;

  /// Solo para tests: si se pasan, la página no depende de [AuthSessionCubit].
  final AppUser? user;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<ProfileRepository>();
    final sesion = (user != null || onSignOut != null)
        ? user
        : context.watch<AuthSessionCubit>().state.user;
    return BlocProvider(
      create: (_) => PerfilCubit(repo)..load(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppPageHeader(title: 'Mi perfil'),
              Expanded(
                child: BlocBuilder<PerfilCubit, PerfilState>(
                  builder: (context, state) => UiStateView<PerfilEstudiante>(
                    state: state.perfil,
                    dataBuilder: (context, perfil) => _Contenido(
                      perfil: perfil,
                      user: sesion,
                      onSignOut: onSignOut ??
                          () => context.read<AuthSessionCubit>().signOut(),
                    ),
                  ),
                ),
              ),
              const StudentBottomNav(currentIndex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.perfil,
    required this.user,
    required this.onSignOut,
  });

  final PerfilEstudiante perfil;
  final AppUser? user;
  final VoidCallback onSignOut;

  String get _iniciales {
    final partes = (user?.displayName ?? 'Estudiante')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2);
    return partes.map((p) => p[0].toUpperCase()).join();
  }

  Future<void> _confirmarSalida(BuildContext context) async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text(
          'Tendrás que volver a ingresar tu correo y contraseña.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (salir == true) onSignOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contacto = perfil.contactoEmergencia;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        AppCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  _iniciales,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Estudiante',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (user != null)
                      Text(
                        user!.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    const AppStatusChip(
                      label: 'Estudiante aprobado',
                      tone: AppStatusTone.success,
                      icon: Icons.verified_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const AppSectionTitle('Datos académicos'),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInfoRow(label: 'Matrícula', value: perfil.matricula),
              AppInfoRow(label: 'Carrera', value: perfil.carrera),
              AppInfoRow(
                label: 'Credencial',
                value: perfil.credencialAprobadaEl == null
                    ? perfil.credencial.texto
                    : '${perfil.credencial.texto} · ${Formatos.fechaCortaAnio(perfil.credencialAprobadaEl!)}',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const Expanded(child: AppSectionTitle('Contacto')),
            TextButton.icon(
              onPressed: () => mostrarEditarContacto(context, perfil),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Editar'),
            ),
          ],
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInfoRow(label: 'Teléfono', value: perfil.telefono),
              AppInfoRow(
                label: 'Contacto de emergencia',
                value: contacto == null
                    ? 'Sin registrar'
                    : '${contacto.nombre} · ${contacto.parentesco} · ${contacto.telefono}',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _Opcion(
                icon: Icons.assignment_outlined,
                title: 'Mis reportes',
                subtitle: 'Consulta el estado de tus reportes',
                onTap: () => context.push(AppRoutes.myIncidents),
              ),
              const Divider(height: 1),
              _Opcion(
                icon: Icons.report_outlined,
                title: 'Reportar un incidente',
                onTap: () => context.push(AppRoutes.incidents),
              ),
              const Divider(height: 1),
              _Opcion(
                icon: Icons.settings_outlined,
                title: 'Ajustes',
                subtitle: 'Notificaciones, permisos y privacidad',
                onTap: () => context.push(AppRoutes.settings),
              ),
              const Divider(height: 1),
              _Opcion(
                icon: Icons.privacy_tip_outlined,
                title: 'Aviso de privacidad',
                onTap: () => context.push(AppRoutes.privacy),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () => _confirmarSalida(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            minimumSize: const Size(0, 48),
            side: const BorderSide(color: AppColors.error),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
      onTap: onTap,
    );
  }
}
