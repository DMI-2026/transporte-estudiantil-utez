/// Validaciones del formulario de reporte (F5: validación en el cliente).
abstract final class ReporteValidator {
  static const maxDescripcion = 500;
  static const minDescripcion = 10;

  static String? tipo(String? valor) =>
      (valor == null || valor.isEmpty) ? 'Elige el tipo de incidente.' : null;

  static String? referencia(String? valor) =>
      (valor == null || valor.isEmpty) ? 'Elige la salida relacionada.' : null;

  static String? descripcion(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) {
      return 'Describe lo que pasó.';
    }
    if (texto.length < minDescripcion) {
      return 'Agrega un poco más de detalle (mínimo $minDescripcion caracteres).';
    }
    if (texto.length > maxDescripcion) {
      return 'Máximo $maxDescripcion caracteres.';
    }
    return null;
  }
}
