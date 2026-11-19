part of 'perfil_cubit.dart';

class PerfilState extends Equatable {
  const PerfilState({
    this.perfil = const UiLoading(),
    this.guardando = false,
    this.error,
  });

  final UiState<PerfilEstudiante> perfil;
  final bool guardando;
  final String? error;

  PerfilState copyWith({
    UiState<PerfilEstudiante>? perfil,
    bool? guardando,
    String? error,
    bool clearError = false,
  }) {
    return PerfilState(
      perfil: perfil ?? this.perfil,
      guardando: guardando ?? this.guardando,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [perfil, guardando, error];
}
