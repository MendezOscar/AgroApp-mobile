import 'package:dio/dio.dart';

class CropsRemoteDatasource {
  final Dio _dio;

  CropsRemoteDatasource(this._dio);

  Future<List<dynamic>> getCrops(String plotId) async {
    final response = await _dio.get('/plots/$plotId/crops');
    return response.data;
  }

  Future<Map<String, dynamic>> createCrop(
      String plotId, Map<String, dynamic> data) async {
    final response = await _dio.post('/plots/$plotId/crops', data: data);
    return response.data;
  }

  Future<void> deleteCrop(String plotId, String cropId) async {
    await _dio.delete('/plots/$plotId/crops/$cropId');
  }
}
