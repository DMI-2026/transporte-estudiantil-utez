import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mensaje_estado.dart';
import '../../domain/repositories/auth_repository.dart';
import 'login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.repository});

  final AuthRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? getIt<AuthRepository>();
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
              if (!widget.backendDisponible)
                const MensajeEstado(
                  compact: true,
                  icono: Icons.cloud_off_outlined,
                  titulo: 'Firebase desactivado',
                  detalle:
                      'Copia env/example.json a env/dev.json con USE_FIREBASE true y añade firebase_options.dart.',
                ),
              if (state.status == LoginStatus.failure && state.message != null)
                MensajeEstado(
                  compact: true,
                  icono: Icons.error_outline,
                  titulo: 'No pudimos iniciar sesión',
                  detalle: state.message!,
                ),
              Text(
                'Transporte Estudiantil UTEZ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                key: const Key('campo-correo'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                key: const Key('campo-contrasena'),
                controller: _passwordController,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: loading
                    ? null
                    : () => context.read<LoginCubit>().submit(
                        email: _emailController.text,
                        password: _passwordController.text,
                      ),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Entrar'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.push(AppRoutes.register),
                child: const Text('Crear cuenta'),
              ),
            ],
          );
        },
      ),
    );
  }
}
