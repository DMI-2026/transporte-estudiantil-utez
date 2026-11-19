/// Formatos de fecha, hora y dinero en español (México) sin depender de intl.
abstract final class Formatos {
  static const _meses = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  static const _mesesLargos = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
    'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  /// "26 oct".
  static String fechaCorta(DateTime f) => '${f.day} ${_meses[f.month - 1]}';

  /// "26 oct 2026".
  static String fechaCortaAnio(DateTime f) => '${fechaCorta(f)} ${f.year}';

  /// "26 de octubre de 2026".
  static String fechaLarga(DateTime f) =>
      '${f.day} de ${_mesesLargos[f.month - 1]} de ${f.year}';

  /// "06:40".
  static String hora(DateTime f) =>
      '${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';

  /// "\$20.00 MXN".
  static String dinero(double monto) => '\$${monto.toStringAsFixed(2)} MXN';
}
