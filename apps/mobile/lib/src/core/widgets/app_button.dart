import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, danger }

/// Botón base del sistema UTEZ con variantes del diseño de Figma.
///
/// La variante primaria usa `FilledButton`, la secundaria `OutlinedButton`
/// y la de peligro un `FilledButton` con el color de error del tema.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = !loading && onPressed != null;
    final foreground = variant == AppButtonVariant.secondary
        ? AppColors.primary
        : AppColors.onPrimary;
    final child = loading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(foreground),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(label),
            ],
          )
        : icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(label),
            ],
          );

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: enabled ? onPressed : null,
        style: _filledStyle(AppColors.primary),
        child: child,
      ),
      AppButtonVariant.danger => FilledButton(
        onPressed: enabled ? onPressed : null,
        style: _filledStyle(AppColors.error),
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 48),
          side: BorderSide(
            color: enabled ? AppColors.primary : AppColors.outline,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
        child: child,
      ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  ButtonStyle _filledStyle(Color background) {
    return FilledButton.styleFrom(
      backgroundColor: background,
      foregroundColor: AppColors.onPrimary,
      disabledBackgroundColor: AppColors.outline,
      disabledForegroundColor: AppColors.muted,
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
    );
  }
}
