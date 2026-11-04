import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/entities/user_role.dart';
import 'package:transporte_estudiantil/src/features/auth/domain/validators/registration_validator.dart';

void main() {
  group('RegistrationValidator', () {
    test('estudiante requiere correo @utez.edu.mx', () {
      expect(
        RegistrationValidator.emailError('a@utez.edu.mx', UserRole.estudiante),
        isNull,
      );
      expect(
        RegistrationValidator.emailError('a@gmail.com', UserRole.estudiante),
        isNotNull,
      );
    });

    test('operador acepta correo genérico', () {
      expect(
        RegistrationValidator.emailError('op@mail.com', UserRole.operador),
        isNull,
      );
    });
  });
}
