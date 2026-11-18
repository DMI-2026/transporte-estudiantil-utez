import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import 'app_bottom_nav.dart';

/// Barra inferior del estudiante: inicio y rutas.
class StudentBottomNav extends StatelessWidget {
  const StudentBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return AppBottomNav(
      currentIndex: currentIndex,
      onSelected: (index) {
        final location = index == 0 ? AppRoutes.home : AppRoutes.routes;
        context.go(location);
      },
      items: const [
        AppNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Inicio',
        ),
        AppNavItem(
          icon: Icons.alt_route_outlined,
          activeIcon: Icons.alt_route,
          label: 'Rutas',
        ),
      ],
    );
  }
}
