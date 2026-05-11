import 'package:dio/dio.dart';

class SensorsRemoteDatasource {
  final Dio _dio;
  SensorsRemoteDatasource(this._dio);

  Future<List<dynamic>> getSensorDevices(String plotId) async {
    final response = await _dio.get('/plots/$plotId/sensors');
    return response.data;
  }

  Future<List<dynamic>> getSensorReadings(String deviceId,
      {int limit = 50}) async {
    final response = await _dio
        .get('/sensors/$deviceId/readings', queryParameters: {'limit': limit});
    return response.data;
  }

  Future<Map<String, dynamic>?> getLatestReading(String deviceId) async {
    try {
      final response = await _dio.get('/sensors/$deviceId/readings/latest');
      return response.data;
    } catch (_) {
      return null;
    }
  }
}
