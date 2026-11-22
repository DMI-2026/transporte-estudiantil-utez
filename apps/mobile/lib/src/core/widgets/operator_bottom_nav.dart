import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import 'app_bottom_nav.dart';

/// Barra inferior del operador: salidas, abordaje, reportes y perfil.
class OperatorBottomNav extends StatelessWidget {
  const OperatorBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  static const _destinos = [
    AppRoutes.operatorDashboard,
    AppRoutes.operatorAbordaje,
    AppRoutes.operatorReportes,
    AppRoutes.operatorPerfil,
  ];

  @override
  Widget build(BuildContext context) {
    return AppBottomNav(
      currentIndex: currentIndex,
      onSelected: (index) => context.go(_destinos[index]),
      items: const [
        AppNavItem(
          icon: Icons.calendar_month_outlined,
          activeIcon: Icons.calendar_month,
          label: 'Salidas',
        ),
        AppNavItem(
          icon: Icons.qr_code_scanner_outlined,
          activeIcon: Icons.qr_code_scanner,
          label: 'Abordaje',
        ),
        AppNavItem(
          icon: Icons.assignment_outlined,
          activeIcon: Icons.assignment,
          label: 'Reportes',
        ),
        AppNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Perfil',
        ),
      ],
    );
  }
}
