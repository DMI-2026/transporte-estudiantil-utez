import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/theme/app_colors.dart';
import 'package:transporte_estudiantil/src/core/widgets/app_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('la variante primaria responde al toque', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(AppButton(label: 'Entrar', onPressed: () => taps++)),
    );

    await tester.tap(find.text('Entrar'));

    expect(taps, 1);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('la variante secundaria usa OutlinedButton', (tester) async {
    await tester.pumpWidget(
      wrap(
        AppButton(
          label: 'Cancelar',
          variant: AppButtonVariant.secondary,
          onPressed: () {},
        ),
      ),
    );

    expect(find.byType(OutlinedButton), findsOneWidget);
  });

  testWidgets('la variante de peligro usa el color de error', (tester) async {
    await tester.pumpWidget(
      wrap(
        AppButton(
          label: 'Eliminar',
          variant: AppButtonVariant.danger,
          onPressed: () {},
        ),
      ),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(
      button.style?.backgroundColor?.resolve(<WidgetState>{}),
      AppColors.error,
    );
  });

  testWidgets('en carga se deshabilita y muestra indicador', (tester) async {
    await tester.pumpWidget(
      wrap(AppButton(label: 'Guardar', loading: true, onPressed: () {})),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
