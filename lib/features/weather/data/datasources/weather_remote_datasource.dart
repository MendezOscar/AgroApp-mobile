import 'package:dio/dio.dart';
import '../models/weather_model.dart';

/// Cliente standalone para Open-Meteo (sin API key, sin auth) — no usa el
/// Dio compartido del backend de AgroApp, que inyecta el Bearer token.
class WeatherRemoteDatasource {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.open-meteo.com/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<WeatherModel?> getCurrentWeather(double lat, double lng) async {
    try {
      final response = await _dio.get('/forecast', queryParameters: {
        'latitude': lat,
        'longitude': lng,
        'current': 'temperature_2m,precipitation,weather_code',
        'daily': 'precipitation_sum',
        'timezone': 'auto',
        'forecast_days': 1,
      });
      return WeatherModel.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }
}
