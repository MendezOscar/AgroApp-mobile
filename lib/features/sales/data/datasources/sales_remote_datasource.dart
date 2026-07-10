import 'package:dio/dio.dart';

class SalesRemoteDatasource {
  final Dio _dio;
  SalesRemoteDatasource(this._dio);

  Future<List<dynamic>> getSales(String cropId) async {
    final response = await _dio.get('/crops/$cropId/sales');
    return response.data;
  }

  Future<Map<String, dynamic>> createSale(
      String cropId, Map<String, dynamic> data) async {
    final response = await _dio.post('/crops/$cropId/sales', data: data);
    return response.data;
  }
}
