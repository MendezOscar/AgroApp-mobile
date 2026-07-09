import 'dart:convert';
import 'dart:math';
import 'package:latlong2/latlong.dart';

LatLng? decodeGeoPoint(String? geoJson) {
  if (geoJson == null || geoJson.isEmpty) return null;
  try {
    final data = jsonDecode(geoJson) as Map<String, dynamic>;
    if (data['type'] != 'Point') return null;
    final coords = data['coordinates'] as List;
    final lng = (coords[0] as num).toDouble();
    final lat = (coords[1] as num).toDouble();
    return LatLng(lat, lng);
  } catch (_) {
    return null;
  }
}

String encodeGeoPoint(LatLng point) {
  return jsonEncode({
    'type': 'Point',
    'coordinates': [point.longitude, point.latitude],
  });
}

List<LatLng>? decodeGeoPolygon(String? geoJson) {
  if (geoJson == null || geoJson.isEmpty) return null;
  try {
    final data = jsonDecode(geoJson) as Map<String, dynamic>;
    if (data['type'] != 'Polygon') return null;
    final rings = data['coordinates'] as List;
    if (rings.isEmpty) return null;
    final ring = (rings[0] as List)
        .map((c) => LatLng(
              (c[1] as num).toDouble(),
              (c[0] as num).toDouble(),
            ))
        .toList();
    // El anillo viene cerrado (primer punto repetido al final); lo quitamos.
    if (ring.length > 1 && ring.first == ring.last) {
      ring.removeLast();
    }
    return ring;
  } catch (_) {
    return null;
  }
}

String encodeGeoPolygon(List<LatLng> points) {
  final ring = [
    ...points.map((p) => [p.longitude, p.latitude]),
    [points.first.longitude, points.first.latitude],
  ];
  return jsonEncode({
    'type': 'Polygon',
    'coordinates': [ring],
  });
}

/// Área aproximada en hectáreas usando la fórmula del área de Gauss
/// (shoelace) sobre una proyección equirectangular local. Suficientemente
/// precisa para el tamaño de una parcela agrícola.
double polygonAreaHectares(List<LatLng> points) {
  if (points.length < 3) return 0;

  const metersPerDegreeLat = 110540.0;
  final avgLatRad = points.map((p) => p.latitude).reduce((a, b) => a + b) /
      points.length *
      (pi / 180);
  final metersPerDegreeLng = 111320.0 * cos(avgLatRad);

  final xy = points
      .map((p) => Point(
            p.longitude * metersPerDegreeLng,
            p.latitude * metersPerDegreeLat,
          ))
      .toList();

  double sum = 0;
  for (var i = 0; i < xy.length; i++) {
    final a = xy[i];
    final b = xy[(i + 1) % xy.length];
    sum += a.x * b.y - b.x * a.y;
  }
  final areaM2 = sum.abs() / 2;
  return areaM2 / 10000;
}
