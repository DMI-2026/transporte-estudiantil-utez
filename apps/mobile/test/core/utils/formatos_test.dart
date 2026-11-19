import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/utils/formatos.dart';

void main() {
  final fecha = DateTime(2026, 10, 6, 7, 5);

  test('formatea fechas en español', () {
    expect(Formatos.fechaCorta(fecha), '6 oct');
    expect(Formatos.fechaCortaAnio(fecha), '6 oct 2026');
    expect(Formatos.fechaLarga(fecha), '6 de octubre de 2026');
  });

  test('formatea hora con dos dígitos y dinero en MXN', () {
    expect(Formatos.hora(fecha), '07:05');
    expect(Formatos.dinero(20), r'$20.00 MXN');
  });
}
