import 'package:dio/dio.dart';

class FertilizationRemoteDatasource {
  final Dio _dio;
  FertilizationRemoteDatasource(this._dio);

  Future<Map<String, dynamic>> getFertilizations(
    String cropId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get('/crops/$cropId/fertilization',
        queryParameters: {'page': page, 'pageSize': pageSize});
    return response.data;
  }

  Future<Map<String, dynamic>> createFertilization(
      String cropId, Map<String, dynamic> data) async {
    final response =
        await _dio.post('/crops/$cropId/fertilization', data: data);
    return response.data;
  }

  Future<void> deleteFertilization(String cropId, String id) async {
    await _dio.delete('/crops/$cropId/fertilization/$id');
  }
}
