import 'package:flutter/material.dart';

/// Colores tomados del logotipo público 2026 de la UTEZ (C-11).
abstract final class AppColors {
  static const primary = Color(0xFF008070);
  static const primarySoft = Color(0xFFD6EDE9);
  static const ink = Color(0xFF183050);
  static const muted = Color(0xFF5A6B7A);
  static const surface = Color(0xFFF4F7F6);
  static const error = Color(0xFFB3261E);
  static const onPrimary = Color(0xFFFFFFFF);
}

/// Espaciados base (múltiplos de 4).
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

/// Radios de esquina.
abstract final class AppRadii {
  static const sm = 12.0;
  static const md = 18.0;
  static const lg = 22.0;
}
