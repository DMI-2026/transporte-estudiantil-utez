part of 'reportar_incidente_cubit.dart';

class ReportarIncidenteState extends Equatable {
  const ReportarIncidenteState({
    this.referencias = const UiLoading(),
    this.tipo,
    this.referencia,
    this.descripcion = '',
    this.evidencia,
    this.mostrarErrores = false,
    this.enviando = false,
    this.error,
    this.enviado,
  });

  final UiState<List<String>> referencias;
  final String? tipo;
  final String? referencia;
  final String descripcion;
  final String? evidencia;
  final bool mostrarErrores;
  final bool enviando;
  final String? error;
  final Reporte? enviado;

  String? get errorTipo =>
      mostrarErrores ? ReporteValidator.tipo(tipo) : null;
  String? get errorReferencia =>
      mostrarErrores ? ReporteValidator.referencia(referencia) : null;
  String? get errorDescripcion =>
      mostrarErrores ? ReporteValidator.descripcion(descripcion) : null;

  bool get esValido =>
      ReporteValidator.tipo(tipo) == null &&
      ReporteValidator.referencia(referencia) == null &&
      ReporteValidator.descripcion(descripcion) == null;

  ReportarIncidenteState copyWith({
    UiState<List<String>>? referencias,
    String? tipo,
    String? referencia,
    String? descripcion,
    String? evidencia,
    bool? mostrarErrores,
    bool? enviando,
    String? error,
    Reporte? enviado,
    bool clearError = false,
    bool clearEvidencia = false,
  }) {
    return ReportarIncidenteState(
      referencias: referencias ?? this.referencias,
      tipo: tipo ?? this.tipo,
      referencia: referencia ?? this.referencia,
      descripcion: descripcion ?? this.descripcion,
      evidencia: clearEvidencia ? null : evidencia ?? this.evidencia,
      mostrarErrores: mostrarErrores ?? this.mostrarErrores,
      enviando: enviando ?? this.enviando,
      error: clearError ? null : error ?? this.error,
      enviado: enviado ?? this.enviado,
    );
  }

  @override
  List<Object?> get props => [
    referencias,
    tipo,
    referencia,
    descripcion,
    evidencia,
    mostrarErrores,
    enviando,
    error,
    enviado,
  ];
}
