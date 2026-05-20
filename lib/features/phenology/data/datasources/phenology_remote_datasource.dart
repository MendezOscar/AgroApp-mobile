import 'package:dio/dio.dart';

class PhenologyRemoteDatasource {
  final Dio _dio;
  PhenologyRemoteDatasource(this._dio);

  Future<List<dynamic>> getStages(String cropId) async {
    final response = await _dio.get('/crops/$cropId/phenology');
    return response.data;
  }

  Future<List<dynamic>> getTemplates(String cropType) async {
    final response =
        await _dio.get('/phenology/templates/${cropType.toLowerCase()}');
    return response.data;
  }

  Future<Map<String, dynamic>> createStage(
      String cropId, Map<String, dynamic> data) async {
    final response = await _dio.post('/crops/$cropId/phenology', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> updateStage(
      String cropId, String stageId, Map<String, dynamic> data) async {
    final response =
        await _dio.patch('/crops/$cropId/phenology/$stageId', data: data);
    return response.data;
  }
}
