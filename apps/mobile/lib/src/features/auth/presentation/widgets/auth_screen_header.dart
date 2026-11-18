import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'auth_brand_block.dart';

/// Encabezado de las pantallas de sesión, alineado al marco del Figma.
class AuthScreenHeader extends StatelessWidget {
  const AuthScreenHeader({
    super.key,
    required this.title,
    this.heroHeadline,
    this.trailing,
    this.showBrand = true,
  });

  final String title;
  final String? heroHeadline;
  final Widget? trailing;
  final bool showBrand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRANSPORTE ESTUDIANTIL',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
        if (showBrand) ...[
          const SizedBox(height: AppSpacing.lg),
          const AuthBrandBlock(),
        ],
        if (heroHeadline != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            heroHeadline!,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

/// Acción decorativa del encabezado de auth (notificaciones tras iniciar sesión).
class AuthScreenHeaderTrailing extends StatelessWidget {
  const AuthScreenHeaderTrailing({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notificaciones',
      onPressed:
          onPressed ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Las notificaciones están disponibles tras iniciar sesión.'),
              ),
            );
          },
      icon: const Icon(Icons.notifications_none_outlined),
    );
  }
}