import 'package:dio/dio.dart';

class FarmsRemoteDatasource {
  final Dio _dio;

  FarmsRemoteDatasource(this._dio);

  Future<List<dynamic>> getFarms() async {
    final response = await _dio.get('/farms');
    return response.data;
  }

  Future<Map<String, dynamic>> createFarm(Map<String, dynamic> data) async {
    final response = await _dio.post('/farms', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> updateFarm(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/farms/$id', data: data);
    return response.data;
  }

  Future<void> deleteFarm(String id) async {
    await _dio.delete('/farms/$id');
  }
}
