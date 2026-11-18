import 'package:equatable/equatable.dart';

class BusRoute extends Equatable {
  const BusRoute({required this.id, required this.nombre, this.descripcion});

  final String id;
  final String nombre;
  final String? descripcion;

  @override
  List<Object?> get props => [id, nombre, descripcion];
}
