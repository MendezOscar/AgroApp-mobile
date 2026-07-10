import 'package:dio/dio.dart';

class SoilAnalysisRemoteDatasource {
  final Dio _dio;

  SoilAnalysisRemoteDatasource(this._dio);

  Future<List<dynamic>> getAnalyses(String plotId) async {
    final response = await _dio.get('/plots/$plotId/soil-analyses');
    return response.data;
  }

  Future<Map<String, dynamic>> createAnalysis(
      String plotId, Map<String, dynamic> data) async {
    final response =
        await _dio.post('/plots/$plotId/soil-analyses', data: data);
    return response.data;
  }
}
