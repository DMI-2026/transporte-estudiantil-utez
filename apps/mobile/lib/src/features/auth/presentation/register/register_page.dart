import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/atoms/app_password_field.dart';
import '../widgets/atoms/app_primary_button.dart';
import '../widgets/atoms/app_text_field.dart';
import '../widgets/auth_alternate_route_link.dart';
import '../widgets/auth_role_context.dart';
import '../widgets/auth_screen_footer.dart';
import '../widgets/auth_screen_header.dart';
import 'register_cubit.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key, this.repository});

  final AuthRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RegisterCubit(repository ?? context.read<AuthRepository>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.estudiante;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = AuthRoleContext.registerInfo(_role);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<RegisterCubit, RegisterState>(
          builder: (context, state) {
            final loading = state.status == RegisterStatus.loading;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const AuthScreenHeader(
                  title: 'Crea tu cuenta',
                  heroHeadline: 'Solicita acceso al transporte estudiantil.',
                  trailing: AuthScreenHeaderTrailing(),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (state.status == RegisterStatus.failure &&
                    state.message != null) ...[
                  AppAlert(
                    tone: AppAlertTone.danger,
                    title: 'No pudimos crear la cuenta',
                    message: state.message!,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Text(
                  AuthRoleContext.registerFormLead(_role),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  key: const Key('campo-nombre'),
                  label: 'Nombre completo *',
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  key: const Key('campo-correo'),
                  label: 'Correo *',
                  helperText: 'Estudiantes: @utez.edu.mx',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.md),
                AppPasswordField(
                  key: const Key('campo-contrasena'),
                  label: 'Contraseña *',
                  controller: _passwordController,
                ),
                const SizedBox(height: AppSpacing.md),
                SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(
                      value: UserRole.estudiante,
                      label: Text('Estudiante'),
                    ),
                    ButtonSegment(
                      value: UserRole.operador,
                      label: Text('Operador'),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (set) => setState(() => _role = set.first),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: 'Registrarme',
                  icon: Icons.arrow_forward,
                  loading: loading,
                  onPressed: () => context.read<RegisterCubit>().submit(
                    email: _emailController.text,
                    password: _passwordController.text,
                    displayName: _nameController.text,
                    role: _role,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AuthAlternateRouteLink(
                  prompt: '¿Ya tienes cuenta?',
                  linkLabel: 'Inicia sesión',
                  onLinkTap: () => context.push(AppRoutes.login),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppAlert(
                  tone: info.tone,
                  title: info.title,
                  message: info.message,
                ),
                const SizedBox(height: AppSpacing.xl),
                const AuthScreenFooter(),
              ],
            );
          },
        ),
      ),
    );
  }
}