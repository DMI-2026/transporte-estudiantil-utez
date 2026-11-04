import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppAlertTone { success, warning, danger, info }

/// Aviso en línea para mensajes de éxito, advertencia, error o información.
class AppAlert extends StatelessWidget {
  const AppAlert({
    super.key,
    required this.title,
    this.message,
    this.tone = AppAlertTone.info,
    this.icon,
    this.action,
    this.onClose,
  });

  final String title;
  final String? message;
  final AppAlertTone tone;
  final IconData? icon;
  final Widget? action;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, defaultIcon) = switch (tone) {
      AppAlertTone.success => (
        AppColors.primarySoft,
        AppColors.primary,
        Icons.check_circle_outline,
      ),
      AppAlertTone.warning => (
        AppColors.warningSoft,
        AppColors.warning,
        Icons.warning_amber_rounded,
      ),
      AppAlertTone.danger => (
        AppColors.errorSoft,
        AppColors.error,
        Icons.error_outline,
      ),
      AppAlertTone.info => (
        AppColors.infoSoft,
        AppColors.info,
        Icons.info_outline,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: foreground.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, size: 20, color: foreground),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.ink),
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  action!,
                ],
              ],
            ),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 18),
              color: foreground,
              tooltip: 'Cerrar aviso',
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
