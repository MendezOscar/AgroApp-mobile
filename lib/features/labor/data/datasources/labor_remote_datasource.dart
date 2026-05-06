import 'package:dio/dio.dart';

class LaborRemoteDatasource {
  final Dio _dio;
  LaborRemoteDatasource(this._dio);

  Future<List<dynamic>> getLabors(String cropId) async {
    final response = await _dio.get('/crops/$cropId/labor');
    return response.data;
  }

  Future<Map<String, dynamic>> createLabor(
      String cropId, Map<String, dynamic> data) async {
    final response = await _dio.post('/crops/$cropId/labor', data: data);
    return response.data;
  }

  Future<void> deleteLabor(String cropId, String id) async {
    await _dio.delete('/crops/$cropId/labor/$id');
  }
}
