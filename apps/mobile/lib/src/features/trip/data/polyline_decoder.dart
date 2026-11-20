import '../domain/entities/viaje_en_curso.dart';

/// Decodifica una polilínea encoded (Google / ORS) a puntos WGS84.
abstract final class PolylineDecoder {
  static List<PuntoMapa> decode(String encoded) {
    if (encoded.isEmpty) return const [];
    final points = <PuntoMapa>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(PuntoMapa(latitud: lat / 1e5, longitud: lng / 1e5));
    }
    return points;
  }
}
