import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppStatusTone { success, warning, danger, neutral }

/// Etiqueta compacta para estados de cuenta, reservas o pagos.
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    this.tone = AppStatusTone.neutral,
    this.icon,
  });

  final String label;
  final AppStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      AppStatusTone.success => (AppColors.primarySoft, AppColors.primary),
      AppStatusTone.warning => (AppColors.warningSoft, AppColors.warning),
      AppStatusTone.danger => (AppColors.errorSoft, AppColors.error),
      AppStatusTone.neutral => (AppColors.surface, AppColors.muted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
