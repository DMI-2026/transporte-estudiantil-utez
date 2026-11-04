import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/atoms/app_primary_button.dart';
import '../widgets/atoms/app_text_field.dart';
import 'login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.repository});

  final AuthRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<AuthRepository>();
    return BlocProvider(
      create: (_) => LoginCubit(repo),
      child: _LoginView(backendDisponible: repo.isAvailable),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({required this.backendDisponible});

  final bool backendDisponible;

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final loading = state.status == LoginStatus.loading;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (!widget.backendDisponible) ...[
                const AppAlert(
                  tone: AppAlertTone.warning,
                  title: 'Firebase desactivado',
                  message: 'Copia env/example.json a env/dev.json con USE_FIREBASE true y añade firebase_options.dart.',
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (state.status == LoginStatus.failure &&
                  state.message != null) ...[
                AppAlert(
                  tone: AppAlertTone.danger,
                  title: 'No pudimos iniciar sesión',
                  message: state.message!,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Text(
                'Transporte Estudiantil UTEZ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                key: const Key('campo-correo'),
                label: 'Correo',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                key: const Key('campo-contrasena'),
                label: 'Contraseña',
                controller: _passwordController,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                label: 'Entrar',
                loading: loading,
                onPressed: () => context.read<LoginCubit>().submit(
                  email: _emailController.text,
                  password: _passwordController.text,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Crear cuenta',
                variant: AppButtonVariant.secondary,
                expand: true,
                onPressed: () => context.push(AppRoutes.register),
              ),
            ],
          );
        },
      ),
    );
  }
}
