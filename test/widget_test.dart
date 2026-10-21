import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/app/app.dart';
import 'package:transporte_estudiantil/src/core/di/injection.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  testWidgets('la pantalla de arranque muestra el nombre de la app', (
    tester,
  ) async {
    await tester.pumpWidget(const TransporteApp());

    expect(find.text('Transporte Estudiantil UTEZ'), findsOneWidget);
  });
}
