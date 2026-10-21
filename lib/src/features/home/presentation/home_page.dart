import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Transporte Estudiantil UTEZ')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transporte exclusivo estudiantil',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Reserva tu lugar, sigue la combi y aborda con QR.',
              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
