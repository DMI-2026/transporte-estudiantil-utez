import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// El enunciado no fija una fuente institucional. Source Sans 3 queda
/// centralizada aquí para sustituirla si el equipo confirma otra.
abstract final class AppTypography {
  static TextTheme textTheme(TextTheme base) {
    return GoogleFonts.sourceSans3TextTheme(base);
  }
}
