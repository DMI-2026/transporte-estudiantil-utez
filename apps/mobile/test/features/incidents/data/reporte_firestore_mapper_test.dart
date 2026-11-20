import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/incidents/data/models/reporte_firestore_mapper.dart';
import 'package:transporte_estudiantil/src/features/incidents/domain/entities/reporte.dart';

void main() {
  group('ReporteFirestoreMapper', () {
    test('desde arma el reporte con fotoUrl como evidencia', () {
      final reporte = ReporteFirestoreMapper.desde(
        id: 'inc-1',
        data: {
          'tipo': 'Retraso de la unidad',
          'descripcion': 'Llegó 20 minutos tarde',
          'estado': 'abierto',
          'salidaId': 'demo-salida',
          'fotoUrl': 'https://example.com/foto.jpg',
          'creadoEn': Timestamp.fromDate(DateTime(2026, 11, 1, 7)),
        },
      );

      expect(reporte, isNotNull);
      expect(reporte!.folio, 'inc-1');
      expect(reporte.estado, EstadoReporte.abierto);
      expect(reporte.referencia, 'demo-salida');
      expect(reporte.evidencia, 'https://example.com/foto.jpg');
    });

    test('desde rechaza estado desconocido', () {
      expect(
        ReporteFirestoreMapper.desde(
          id: 'x',
          data: {
            'tipo': 'Otro',
            'descripcion': 'x',
            'estado': 'raro',
            'creadoEn': Timestamp.now(),
          },
        ),
        isNull,
      );
    });

    test('salidaIdDesdeReferencia toma la parte antes del punto medio', () {
      expect(
        ReporteFirestoreMapper.salidaIdDesdeReferencia('sal-1 · Combi 01'),
        'sal-1',
      );
    });
  });
}
