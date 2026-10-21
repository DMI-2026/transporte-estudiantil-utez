import 'package:flutter/foundation.dart';

/// Registro de diagnóstico. En release no imprime nada.
///
/// No pases correo, token, qrToken ni coordenadas: el mensaje se escribe tal
/// cual en depuración.
abstract final class AppLogger {
  static void info(String message) {
    if (kReleaseMode) {
      return;
    }
    debugPrint(message);
  }

  static void error(String message) {
    if (kReleaseMode) {
      return;
    }
    debugPrint(message);
  }
}
