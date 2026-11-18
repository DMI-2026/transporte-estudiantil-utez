import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Marca UTEZ con ícono de transporte, común en pantallas de sesión.
class AuthBrandBlock extends StatelessWidget {
  const AuthBrandBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: const Icon(
            Icons.directions_bus_filled_outlined,
            color: AppColors.onPrimary,
            size: 28,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UTEZ',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Transporte estudiantil',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          ],
          ),
        ),
      ],
    );
  }
}