import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/incidents/domain/validators/reporte_validator.dart';

void main() {
  test('tipo y salida son obligatorios', () {
    expect(ReporteValidator.tipo(null), isNotNull);
    expect(ReporteValidator.tipo('Otro'), isNull);
    expect(ReporteValidator.referencia(''), isNotNull);
    expect(ReporteValidator.referencia('SAL-001 · Combi 01'), isNull);
  });

  test('la descripción pide entre 10 y 500 caracteres', () {
    expect(ReporteValidator.descripcion('   '), 'Describe lo que pasó.');
    expect(ReporteValidator.descripcion('corto'), contains('mínimo'));
    expect(ReporteValidator.descripcion('a' * 501), 'Máximo 500 caracteres.');
    expect(ReporteValidator.descripcion('El asiento está flojo.'), isNull);
  });
}
