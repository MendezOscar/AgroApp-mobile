import 'package:dio/dio.dart';

class PlotsRemoteDatasource {
  final Dio _dio;

  PlotsRemoteDatasource(this._dio);

  Future<List<dynamic>> getPlots(String farmId) async {
    final response = await _dio.get('/farms/$farmId/plots');
    return response.data;
  }

  Future<Map<String, dynamic>> createPlot(
      String farmId, Map<String, dynamic> data) async {
    final response = await _dio.post('/farms/$farmId/plots', data: data);
    return response.data;
  }

  Future<void> deletePlot(String farmId, String plotId) async {
    await _dio.delete('/farms/$farmId/plots/$plotId');
  }
}
