import 'package:dio/dio.dart';

class CostsRemoteDatasource {
  final Dio _dio;

  CostsRemoteDatasource(this._dio);

  Future<List<dynamic>> getMonthlyCostHistory({int months = 6}) async {
    final response = await _dio.get('/costs/monthly-history',
        queryParameters: {'months': months});
    return response.data;
  }

  Future<List<dynamic>> getPendingCosts(String farmId) async {
    final response = await _dio.get('/farms/$farmId/pending-costs');
    return response.data;
  }

  Future<void> setCost(
    String activityType,
    String cropId,
    String id,
    double cost,
  ) async {
    final path = switch (activityType) {
      'Irrigation' => '/crops/$cropId/irrigation/$id/cost',
      'Fertilization' => '/crops/$cropId/fertilization/$id/cost',
      'Labor' => '/crops/$cropId/labor/$id/cost',
      _ => throw ArgumentError('Tipo de actividad desconocido: $activityType'),
    };
    await _dio.patch(path, data: {'cost': cost});
  }
}
