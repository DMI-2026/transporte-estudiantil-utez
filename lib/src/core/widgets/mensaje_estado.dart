import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Mensaje de vacío o error (equivalente cafetería `MensajeEstado`).
class MensajeEstado extends StatelessWidget {
  const MensajeEstado({
    super.key,
    required this.icono,
    required this.titulo,
    required this.detalle,
    this.textoBoton,
    this.onBoton,
    this.compact = false,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final String? textoBoton;
  final VoidCallback? onBoton;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 56.0 : 96.0;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: compact ? 28 : 40, color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              detalle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            if (textoBoton != null && onBoton != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onBoton,
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(textoBoton!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
