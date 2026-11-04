import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/core/widgets/app_bottom_nav.dart';

void main() {
  testWidgets('muestra los elementos y notifica la selección', (tester) async {
    var selected = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            currentIndex: 0,
            onSelected: (index) => selected = index,
            items: const [
              AppNavItem(icon: Icons.home_outlined, label: 'Inicio'),
              AppNavItem(icon: Icons.route_outlined, label: 'Rutas'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Rutas'), findsOneWidget);

    await tester.tap(find.text('Rutas'));
    expect(selected, 1);
  });
}
