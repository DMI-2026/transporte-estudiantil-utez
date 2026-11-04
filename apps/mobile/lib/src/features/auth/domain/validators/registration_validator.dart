import '../entities/user_role.dart';

abstract final class RegistrationValidator {
  static const _utezDomain = '@utez.edu.mx';

  /// Validación de formato sin regla de dominio (login: cualquier rol).
  static String? loginEmailError(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return 'Ingresa tu correo.';
    }
    final at = trimmed.indexOf('@');
    if (at <= 0 || at == trimmed.length - 1 || trimmed.contains(' ')) {
      return 'Correo no válido.';
    }
    return null;
  }

  static String? emailError(String email, UserRole role) {
    final formatError = loginEmailError(email);
    if (formatError != null) {
      return formatError;
    }
    final trimmed = email.trim();
    if (role == UserRole.estudiante &&
        !trimmed.toLowerCase().endsWith(_utezDomain)) {
      return 'Los estudiantes deben usar correo $_utezDomain';
    }
    return null;
  }

  static String? passwordError(String password) {
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }

  static String? nameError(String name) {
    if (name.trim().isEmpty) {
      return 'Ingresa tu nombre.';
    }
    return null;
  }
}
