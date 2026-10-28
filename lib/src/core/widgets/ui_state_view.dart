import 'package:flutter/material.dart';

import 'mensaje_estado.dart';
import 'ui_state.dart';

typedef UiDataBuilder<T> = Widget Function(BuildContext context, T data);

/// Renderiza [UiState] con loading, error+reintentar, vacío o datos
/// (convención C-11: pantallas remotas con UiState + MensajeEstado).
class UiStateView<T> extends StatelessWidget {
  const UiStateView({
    super.key,
    required this.state,
    required this.dataBuilder,
    this.loading,
    this.emptyMessage,
    this.emptyTitle = 'Sin datos',
  });

  final UiState<T> state;
  final UiDataBuilder<T> dataBuilder;
  final Widget? loading;
  final String? emptyMessage;
  final String emptyTitle;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      UiLoading() =>
        loading ??
            const Center(child: CircularProgressIndicator.adaptive()),
      UiError(:final message, :final onRetry) => MensajeEstado(
        icono: Icons.error_outline,
        titulo: 'No pudimos cargar',
        detalle: message,
        textoBoton: onRetry != null ? 'Reintentar' : null,
        onBoton: onRetry,
      ),
      UiEmpty(:final message) => MensajeEstado(
        icono: Icons.inbox_outlined,
        titulo: emptyTitle,
        detalle: message ?? emptyMessage ?? 'Sin datos por mostrar.',
      ),
      UiData(:final value) => dataBuilder(context, value),
    };
  }
}
