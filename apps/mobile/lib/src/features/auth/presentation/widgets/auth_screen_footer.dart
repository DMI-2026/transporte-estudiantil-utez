import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Pie de pantallas de autenticación: privacidad y datos demo.
class AuthScreenFooter extends StatelessWidget {
  const AuthScreenFooter({
    super.key,
    this.onDemoData,
    this.onPrivacy,
  });

  final VoidCallback? onDemoData;
  final VoidCallback? onPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelSmall?.copyWith(color: AppColors.muted);
    final link = muted?.copyWith(decoration: TextDecoration.underline);

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _FooterTap(
              label: 'Aviso de privacidad',
              style: link,
              onTap: onPrivacy,
            ),
            Text(' · ', style: muted),
            Text('Transporte estudiantil', style: muted),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _FooterTap(
          label: 'Datos de demostración',
          style: link,
          onTap: onDemoData,
        ),
      ],
    );
  }
}

class _FooterTap extends StatelessWidget {
  const _FooterTap({required this.label, required this.style, this.onTap});

  final String label;
  final TextStyle? style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(label, style: style, textAlign: TextAlign.center),
    );
  }
}