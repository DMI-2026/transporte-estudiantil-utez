import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/auth/presentation/widgets/atoms/app_primary_button.dart';
import 'package:transporte_estudiantil/src/features/auth/presentation/widgets/atoms/app_text_field.dart';

void main() {
  group('AppTextField', () {
    testWidgets('muestra la etiqueta y acepta texto', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(label: 'Correo', controller: controller),
          ),
        ),
      );

      expect(find.text('Correo'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'a@utez.edu.mx');
      expect(controller.text, 'a@utez.edu.mx');
    });

    testWidgets('muestra error e icono', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Correo',
              errorText: 'Correo inválido',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
        ),
      );

      expect(find.text('Correo inválido'), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline), findsOneWidget);
    });
  });

  group('AppPrimaryButton', () {
    testWidgets('muestra la etiqueta y responde al toque', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPrimaryButton(
              label: 'Entrar',
              onPressed: () {
                pressed++;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Entrar'));
      expect(pressed, 1);
    });

    testWidgets('en carga se deshabilita y muestra indicador', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPrimaryButton(
              label: 'Entrar',
              loading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });
}
