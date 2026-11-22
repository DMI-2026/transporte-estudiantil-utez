import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/ui_state.dart';
import '../../domain/entities/pasajero.dart';
import '../../domain/entities/salida_operador.dart';
import '../../domain/repositories/operator_repository.dart';

class ListaAbordaje extends Equatable {
  const ListaAbordaje({required this.salida, required this.pasajeros});

  final SalidaOperador salida;
  final List<Pasajero> pasajeros;

  int get abordaron =>
      pasajeros.where((p) => p.estado == EstadoAbordaje.abordada).length;
  int get porAbordar => pasajeros.length - abordaron;

  @override
  List<Object?> get props => [salida, pasajeros];
}

class ListaAbordajeState extends Equatable {
  const ListaAbordajeState({this.lista = const UiLoading(), this.filtro = ''});

  final UiState<ListaAbordaje> lista;
  final String filtro;

  /// Pasajeros que coinciden con el nombre o el folio buscado.
  List<Pasajero> filtrados(ListaAbordaje data) {
    final q = filtro.trim().toLowerCase();
    if (q.isEmpty) return data.pasajeros;
    return [
      for (final p in data.pasajeros)
        if (p.nombre.toLowerCase().contains(q) ||
            p.folio.toLowerCase().contains(q))
          p,
    ];
  }

  @override
  List<Object?> get props => [lista, filtro];
}

/// Pantalla 07 · Lista de abordaje.
class ListaAbordajeCubit extends Cubit<ListaAbordajeState> {
  ListaAbordajeCubit(this._repository, this.salidaId)
    : super(const ListaAbordajeState());

  final OperatorRepository _repository;
  final String salidaId;

  Future<void> load() async {
    emit(ListaAbordajeState(filtro: state.filtro));
    final salida = await _repository.fetchSalida(salidaId);
    final pasajeros = await _repository.fetchPasajeros(salidaId);
    final failure = salida.failure ?? pasajeros.failure;
    if (failure != null) {
      emit(
        ListaAbordajeState(
          lista: UiError(message: failure.userMessage, onRetry: load),
          filtro: state.filtro,
        ),
      );
      return;
    }
    final lista = pasajeros.value ?? const <Pasajero>[];
    emit(
      ListaAbordajeState(
        filtro: state.filtro,
        lista: lista.isEmpty
            ? const UiEmpty(message: 'Esta salida todavía no tiene reservas.')
            : UiData(ListaAbordaje(salida: salida.value!, pasajeros: lista)),
      ),
    );
  }

  void buscar(String texto) =>
      emit(ListaAbordajeState(lista: state.lista, filtro: texto));
}
