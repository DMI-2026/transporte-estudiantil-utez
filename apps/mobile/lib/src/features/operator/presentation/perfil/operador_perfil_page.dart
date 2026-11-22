import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatos.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_info_row.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/operator_bottom_nav.dart';
import '../../../../core/widgets/ui_state.dart';
import '../../../../core/widgets/ui_state_view.dart';
import '../../../auth/presentation/session/auth_session_cubit.dart';
import '../../domain/entities/perfil_operador.dart';
import '../../domain/repositories/operator_repository.dart';
import 'operador_perfil_cubit.dart';

/// Pantalla 10 · Mi perfil (pestaña Perfil del operador).
class OperadorPerfilPage extends StatelessWidget {
  const OperadorPerfilPage({super.key, this.repository, this.onSignOut});

  final OperatorRepository? repository;

  /// Solo para tests: evita depender de [AuthSessionCubit].
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<OperatorRepository>();
    return BlocProvider(
      create: (_) => OperadorPerfilCubit(repo)..load(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppPageHeader(title: 'Mi perfil'),
              Expanded(
                child: BlocBuilder<OperadorPerfilCubit, UiState<PerfilOperador>>(
                  builder: (context, state) => UiStateView<PerfilOperador>(
                    state: state,
                    dataBuilder: (context, p) => _Contenido(
                      perfil: p,
                      onSignOut: onSignOut ??
                          () => context.read<AuthSessionCubit>().signOut(),
                    ),
                  ),
                ),
              ),
              const OperatorBottomNav(currentIndex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.perfil, required this.onSignOut});

  final PerfilOperador perfil;
  final VoidCallback onSignOut;

  void _hoja(BuildContext context, String titulo, List<String> lineas) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            for (final l in lineas)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(l),
              ),
          ],
        ),
      ),
    );
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
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        AppCard(
          color: AppColors.primarySoft,
          borderColor: AppColors.primarySoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                perfil.nombre,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Operador · ${perfil.numero}'),
              const SizedBox(height: AppSpacing.sm),
              AppStatusChip(
                label: perfil.aprobado ? 'Aprobada' : 'En revisión',
                tone: perfil.aprobado
                    ? AppStatusTone.success
                    : AppStatusTone.warning,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInfoRow(
                label: 'Unidad asignada',
                value: '${perfil.unidad} · ${perfil.cupoUnidad} asientos',
              ),
              AppInfoRow(label: 'Correo', value: perfil.correo),
              AppInfoRow(label: 'Teléfono', value: perfil.telefono),
              AppInfoRow(label: 'Dirección', value: perfil.direccion),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInfoRow(
                label: 'Contacto de emergencia',
                value: '${perfil.contactoNombre} · ${perfil.contactoParentesco}',
              ),
              AppInfoRow(label: 'Teléfono', value: perfil.contactoTelefono),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: AppInfoRow(
            label: 'Licencia',
            value:
                '${perfil.licencia} · Vigente hasta ${Formatos.fechaCortaAnio(perfil.vigenciaLicencia)}',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.verified_outlined,
                    color: AppColors.primary),
                title: const Text('Documentos aprobados'),
                subtitle: Text('${perfil.documentos.length} documentos'),
                trailing:
                    const Icon(Icons.chevron_right, color: AppColors.muted),
                onTap: () => _hoja(
                  context,
                  'Documentos aprobados por administración',
                  perfil.documentos,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.key_outlined, color: AppColors.primary),
                title: const Text('Cambiar contraseña'),
                trailing:
                    const Icon(Icons.chevron_right, color: AppColors.muted),
                onTap: () => _hoja(context, 'Cambiar contraseña', const [
                  'Cierra sesión y usa «Olvidé mi contraseña» en el inicio de sesión.',
                ]),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.shield_outlined,
                    color: AppColors.primary),
                title: const Text('Privacidad'),
                trailing:
                    const Icon(Icons.chevron_right, color: AppColors.muted),
                onTap: () => _hoja(context, 'Privacidad', const [
                  'Usamos tus datos de contacto, licencia y documentos para '
                      'verificar tu cuenta y asignarte salidas.',
                  'Los estudiantes solo ven tu nombre corto y la unidad.',
                  'Contenido de demostración; no es un aviso institucional aprobado.',
                ]),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help_outline, color: AppColors.primary),
                title: const Text('Ayuda'),
                trailing:
                    const Icon(Icons.chevron_right, color: AppColors.muted),
                onTap: () => _hoja(context, 'Ayuda', const [
                  'Para cambios de unidad, horarios o datos personales, '
                      'escribe a la coordinación del transporte.',
                  'En una emergencia llama al 911.',
                ]),
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
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Datos de demostración',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}
