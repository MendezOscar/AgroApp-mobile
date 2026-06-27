import 'dart:convert';
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
