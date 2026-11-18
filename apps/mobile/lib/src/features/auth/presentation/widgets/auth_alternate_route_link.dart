import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Enlace secundario del estilo «¿No tienes cuenta? Regístrate».
class AuthAlternateRouteLink extends StatelessWidget {
  const AuthAlternateRouteLink({
    super.key,
    required this.prompt,
    required this.linkLabel,
    required this.onLinkTap,
  });

  final String prompt;
  final String linkLabel;
  final VoidCallback onLinkTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted);

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(prompt, style: baseStyle),
          const SizedBox(width: AppSpacing.xs),
          TextButton(
            onPressed: onLinkTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              linkLabel,
              style: baseStyle?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}