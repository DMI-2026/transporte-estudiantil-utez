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
import '../widgets/auth_demo_credentials.dart';
import '../widgets/auth_role_context.dart';
import '../widgets/auth_screen_footer.dart';
import '../widgets/auth_screen_header.dart';
import 'login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.repository, this.audience = UserRole.estudiante});

  final AuthRepository? repository;

  /// Define textos de ayuda; operadores y administradores usan la misma plantilla.
  final UserRole audience;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? context.read<AuthRepository>();
    return BlocProvider(
      create: (_) => LoginCubit(repo),
      child: _LoginView(
        backendDisponible: repo.isAvailable,
        audience: audience,
      ),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({required this.backendDisponible, required this.audience});

  final bool backendDisponible;
  final UserRole audience;

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

  void _rellenarDemo() {
    setState(() {
      final email = switch (widget.audience) {
        UserRole.estudiante => AuthDemoCredentials.estudianteEmail,
        UserRole.operador => AuthDemoCredentials.operadorEmail,
        UserRole.administrador => AuthDemoCredentials.administradorEmail,
      };
      _emailController.text = email;
      _passwordController.text = AuthDemoCredentials.password;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credenciales de demostración cargadas.')),
    );
  }

  void _olvidarContrasena() {
    final email = _emailController.text.trim();
    final message = email.isEmpty
        ? 'Escribe tu correo institucional y vuelve a tocar el enlace.'
        : 'Si olvidaste la contraseña, contacta a la coordinación del transporte con tu correo $email.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final info = AuthRoleContext.loginInfo(widget.audience);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) {
            final loading = state.status == LoginStatus.loading;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const AuthScreenHeader(
                  title: 'Bienvenida de nuevo',
                  heroHeadline: 'Tu camino a la UTEZ empieza aquí.',
                  trailing: AuthScreenHeaderTrailing(),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (!widget.backendDisponible) ...[
                  const AppAlert(
                    tone: AppAlertTone.warning,
                    title: 'Firebase desactivado',
                    message:
                        'Copia env/example.json a env/dev.json con USE_FIREBASE true y añade firebase_options.dart.',
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
                  AuthRoleContext.loginFormLead(widget.audience),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  key: const Key('campo-correo'),
                  label: 'Correo institucional *',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: AppSpacing.md),
                AppPasswordField(
                  key: const Key('campo-contrasena'),
                  label: 'Contraseña *',
                  controller: _passwordController,
                  autofillHints: const [AutofillHints.password],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _olvidarContrasena,
                    child: const Text('Olvidé mi contraseña'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppPrimaryButton(
                  key: const Key('boton-iniciar-sesion'),
                  label: 'Iniciar sesión',
                  icon: Icons.arrow_forward,
                  loading: loading,
                  onPressed: () => context.read<LoginCubit>().submit(
                    email: _emailController.text,
                    password: _passwordController.text,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AuthAlternateRouteLink(
                  prompt: '¿Aún no tienes cuenta?',
                  linkLabel: 'Regístrate',
                  onLinkTap: () => context.push(AppRoutes.register),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppAlert(
                  tone: info.tone,
                  title: info.title,
                  message: info.message,
                ),
                const SizedBox(height: AppSpacing.xl),
                AuthScreenFooter(
                  onDemoData: _rellenarDemo,
                  onPrivacy: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'El aviso de privacidad estará disponible en el perfil.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}