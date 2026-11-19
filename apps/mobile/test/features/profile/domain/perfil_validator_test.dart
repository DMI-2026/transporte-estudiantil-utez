import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/profile/domain/validators/perfil_validator.dart';

void main() {
  test('el teléfono debe tener 10 dígitos', () {
    expect(PerfilValidator.telefono(''), 'Escribe un teléfono.');
    expect(PerfilValidator.telefono('777 000'), isNotNull);
    expect(PerfilValidator.telefono('777 000 0234'), isNull);
  });

  test('nombre y parentesco son obligatorios', () {
    expect(PerfilValidator.nombre('Al'), isNotNull);
    expect(PerfilValidator.nombre('Ana Ríos'), isNull);
    expect(PerfilValidator.parentesco(' '), isNotNull);
    expect(PerfilValidator.parentesco('Madre'), isNull);
  });
}
