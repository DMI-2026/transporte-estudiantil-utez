import '../../domain/entities/reporte.dart';
import 'incidents_datasource.dart';

/// Reportes de DEMOSTRACIÓN en memoria (Figma, pantallas 12 y 13).
/// El backend real (issues #15 y #16) reemplaza esta clase en `injection.dart`.
class DemoIncidentsDataSource implements IncidentsDataSource {
  DemoIncidentsDataSource({this.latencia = const Duration(milliseconds: 400)});

  final Duration latencia;
  int _siguiente = 26;

  final List<Reporte> _reportes = [
    Reporte(
      folio: 'INC-025',
      tipo: 'Asiento dañado',
      descripcion:
          'El respaldo del asiento junto a la ventana está flojo; avisé al operador.',
      referencia: 'SAL-001 · Combi 01',
      fecha: DateTime(2026, 10, 26, 6, 48),
      estado: EstadoReporte.abierto,
    ),
    Reporte(
      folio: 'INC-024',
      tipo: 'Objeto olvidado',
      descripcion: 'Olvidé una sudadera gris en el último asiento.',
      referencia: 'R01 · Combi 01',
      fecha: DateTime(2026, 10, 23, 8, 10),
      estado: EstadoReporte.enRevision,
      actualizacion:
          'La administración solicitó revisar Combi 01. Actualización: 24 oct, 10:20.',
    ),
  ];

  @override
  Future<List<Reporte>> fetchMisReportes() async {
    await Future<void>.delayed(latencia);
    return List.unmodifiable(_reportes);
  }

  @override
  Future<Reporte> enviar(NuevoReporte reporte) async {
    await Future<void>.delayed(latencia);
    final nuevo = Reporte(
      folio: 'INC-0${_siguiente++}',
      tipo: reporte.tipo,
      descripcion: reporte.descripcion.trim(),
      referencia: reporte.referencia,
      fecha: DateTime.now(),
      estado: EstadoReporte.abierto,
      evidencia: reporte.evidencia,
    );
    _reportes.insert(0, nuevo);
    return nuevo;
  }
}
