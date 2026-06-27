import 'package:dio/dio.dart';

class CostsRemoteDatasource {
  final Dio _dio;

  CostsRemoteDatasource(this._dio);

  Future<List<dynamic>> getMonthlyCostHistory({int months = 6}) async {
    final response = await _dio.get('/costs/monthly-history',
        queryParameters: {'months': months});
    return response.data;
  }
}
