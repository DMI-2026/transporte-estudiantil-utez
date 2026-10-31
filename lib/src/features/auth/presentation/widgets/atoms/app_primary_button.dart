import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_button.dart';

/// Átomo: botón primario UTEZ con estado de carga.
///
/// Se conserva como alias del botón base para no romper los consumidores de
/// autenticación existentes.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      loading: loading,
      icon: icon,
    );
  }
}
