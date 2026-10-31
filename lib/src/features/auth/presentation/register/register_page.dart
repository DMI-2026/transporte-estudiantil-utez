import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/atoms/app_primary_button.dart';
import '../widgets/atoms/app_text_field.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: BlocBuilder<RegisterCubit, RegisterState>(
        builder: (context, state) {
          final loading = state.status == RegisterStatus.loading;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (state.status == RegisterStatus.failure &&
                  state.message != null) ...[
                AppAlert(
                  tone: AppAlertTone.danger,
                  title: 'No pudimos crear la cuenta',
                  message: state.message!,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              AppTextField(
                key: const Key('campo-nombre'),
                label: 'Nombre completo',
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                key: const Key('campo-correo'),
                label: 'Correo',
                helperText: 'Estudiantes: @utez.edu.mx',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                key: const Key('campo-contrasena'),
                label: 'Contraseña',
                controller: _passwordController,
                obscureText: true,
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
                loading: loading,
                onPressed: () => context.read<RegisterCubit>().submit(
                  email: _emailController.text,
                  password: _passwordController.text,
                  displayName: _nameController.text,
                  role: _role,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
