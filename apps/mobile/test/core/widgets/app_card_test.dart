import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/widgets/app_card.dart';

void main() {
  testWidgets('muestra su contenido y responde al toque', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppCard(onTap: () => taps++, child: const Text('Contenido')),
        ),
      ),
    );

    expect(find.text('Contenido'), findsOneWidget);

    await tester.tap(find.text('Contenido'));
    expect(taps, 1);
  });
}
