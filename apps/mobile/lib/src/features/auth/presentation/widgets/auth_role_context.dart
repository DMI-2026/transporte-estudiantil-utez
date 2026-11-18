import '../../../../core/widgets/app_alert.dart';
import '../../domain/entities/user_role.dart';

/// Textos de ayuda según el rol en flujos de sesión.
abstract final class AuthRoleContext {
  static String loginFormLead(UserRole role) => switch (role) {
    UserRole.estudiante => 'Inicia sesión con tu cuenta estudiantil.',
    UserRole.operador => 'Inicia sesión con tu cuenta de operador.',
    UserRole.administrador =>
      'Inicia sesión con tu cuenta de administrador.',
  };

  static String registerFormLead(UserRole role) => switch (role) {
    UserRole.estudiante => 'Completa tus datos para solicitar acceso como estudiante.',
    UserRole.operador => 'Completa tus datos para solicitar acceso como operador.',
    UserRole.administrador =>
      'El rol administrador solo se asigna desde el panel institucional.',
  };

  static ({String title, String message, AppAlertTone tone}) loginInfo(
    UserRole role,
  ) =>
      switch (role) {
        UserRole.estudiante => (
          title: 'Exclusivo para estudiantes',
          message:
              'Tu comprobante se revisa antes de habilitar reservas.',
          tone: AppAlertTone.success,
        ),
        UserRole.operador => (
          title: 'Acceso de operador',
          message:
              'Solo personal autorizado puede validar abordajes y gestionar rutas.',
          tone: AppAlertTone.info,
        ),
        UserRole.administrador => (
          title: 'Acceso administrativo',
          message:
              'Usa las credenciales asignadas por la coordinación del transporte.',
          tone: AppAlertTone.info,
        ),
      };

  static ({String title, String message, AppAlertTone tone}) registerInfo(
    UserRole role,
  ) =>
      switch (role) {
        UserRole.estudiante => (
          title: 'Exclusivo para estudiantes',
          message:
              'Tu comprobante se revisa antes de habilitar reservas.',
          tone: AppAlertTone.success,
        ),
        UserRole.operador => (
          title: 'Cuenta de operador',
          message:
              'Un administrador debe aprobar tu acceso antes de usar la app.',
          tone: AppAlertTone.info,
        ),
        UserRole.administrador => (
          title: 'Sin registro público',
          message:
              'Los administradores son dados de alta solo desde el panel web.',
          tone: AppAlertTone.warning,
        ),
      };
}