import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import 'app_bottom_nav.dart';

/// Barra inferior del estudiante: inicio, rutas, reservas y perfil.
class StudentBottomNav extends StatelessWidget {
  const StudentBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return AppBottomNav(
      currentIndex: currentIndex,
      onSelected: (index) {
        const destinos = [
          AppRoutes.home,
          AppRoutes.routes,
          AppRoutes.reservations,
          AppRoutes.profile,
        ];
        context.go(destinos[index]);
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
        AppNavItem(
          icon: Icons.confirmation_number_outlined,
          activeIcon: Icons.confirmation_number,
          label: 'Reservas',
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
