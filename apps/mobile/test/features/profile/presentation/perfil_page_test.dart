import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/profile/presentation/perfil/perfil_page.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fakes/fake_profile_repository.dart';

void main() {
  testWidgets('muestra datos y confirma antes de cerrar sesión', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    var cerro = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PerfilPage(
          repository: FakeProfileRepository(),
          user: FakeAuthRepository.demoEstudiante,
          onSignOut: () => cerro = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana Demo'), findsOneWidget);
    expect(find.text('202601234'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(cerro, isFalse);

    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(cerro, isTrue);
  });
}
