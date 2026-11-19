/// Validaciones de los datos editables del perfil (F5).
abstract final class PerfilValidator {
  static final _soloDigitos = RegExp(r'\D');

  static String? telefono(String? valor) {
    final digitos = (valor ?? '').replaceAll(_soloDigitos, '');
    if (digitos.isEmpty) return 'Escribe un teléfono.';
    if (digitos.length != 10) return 'El teléfono debe tener 10 dígitos.';
    return null;
  }

  static String? nombre(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe el nombre.';
    if (texto.length < 3) return 'El nombre es muy corto.';
    return null;
  }

  static String? parentesco(String? valor) =>
      (valor?.trim() ?? '').isEmpty ? 'Escribe el parentesco.' : null;
}
