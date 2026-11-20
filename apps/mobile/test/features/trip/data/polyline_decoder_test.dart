import 'package:flutter_test/flutter_test.dart';
import 'package:transporte_estudiantil/src/features/trip/data/polyline_decoder.dart';

void main() {
  test('decode regenera el punto de ejemplo del seed', () {
    // Polilínea corta del seed demo (docs / seed-demo-data).
    final puntos = PolylineDecoder.decode('_p~iF~ps|U_ulLnnqC_mqNvxq`@');
    expect(puntos, isNotEmpty);
    expect(puntos.first.latitud, isNonZero);
    expect(puntos.first.longitud, isNonZero);
  });

  test('cadena vacía no falla', () {
    expect(PolylineDecoder.decode(''), isEmpty);
  });
}
