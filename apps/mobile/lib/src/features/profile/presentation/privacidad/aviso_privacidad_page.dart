import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_info_row.dart';

/// Pantalla 05 · Aviso de privacidad (S6), en modo consulta desde el perfil.
class AvisoPrivacidadPage extends StatelessWidget {
  const AvisoPrivacidadPage({super.key});

  static const _secciones = [
    (
      'Qué usamos',
      'Nombre, correo institucional, teléfono, matrícula, credencial y '
          'contacto de emergencia para revisar tu solicitud y administrar tu cuenta.',
    ),
    (
      'Para qué',
      'Verificar que eres estudiante de la UTEZ, reservar tu lugar, emitir '
          'tu pase de abordaje y atender tus reportes.',
    ),
    (
      'Desde tu teléfono',
      'La cámara, solo mientras tomas una foto de evidencia. Las '
          'notificaciones, solo si las activas en Ajustes.',
    ),
    (
      'Control y conservación',
      'Puedes solicitar acceso, corrección o eliminación de tus datos. El '
          'acceso a tus documentos se limita a tu cuenta y a la administración autorizada.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Aviso de privacidad')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Tus datos, con un propósito claro',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (titulo, texto) in _secciones)
                  AppInfoRow(label: titulo, value: texto),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const AppAlert(
            tone: AppAlertTone.warning,
            title: 'Contenido de demostración',
            message:
                'Este texto no es un aviso institucional aprobado. La coordinación debe sustituirlo por el aviso oficial.',
          ),
        ],
      ),
    );
  }
}
