import 'package:dio/dio.dart';

class IrrigationRemoteDatasource {
  final Dio _dio;
  IrrigationRemoteDatasource(this._dio);

  Future<List<dynamic>> getIrrigations(String cropId) async {
    final response = await _dio.get('/crops/$cropId/irrigation');
    return response.data;
  }

  Future<Map<String, dynamic>> createIrrigation(
      String cropId, Map<String, dynamic> data) async {
    print('ENVIANDO RIEGO: $data'); // ← agrega esto
    final response = await _dio.post('/crops/$cropId/irrigation', data: data);
    return response.data;
  }

  Future<void> deleteIrrigation(String cropId, String id) async {
    await _dio.delete('/crops/$cropId/irrigation/$id');
  }
}
