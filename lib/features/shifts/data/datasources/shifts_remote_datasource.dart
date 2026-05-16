import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class ShiftsRemoteDatasource {
  final Dio _dio;
  ShiftsRemoteDatasource(this._dio);

  Future<List<dynamic>> getTemplates() async {
    final response = await _dio.get('/shifts/templates');
    return response.data;
  }

  Future<Map<String, dynamic>> createTemplate(Map<String, dynamic> data) async {
    final response = await _dio.post('/shifts/templates', data: data);
    return response.data;
  }

  Future<List<dynamic>> getOccurrences({
    DateTime? date,
    bool onlyMine = false,
  }) async {
    final response = await _dio.get('/shifts/occurrences', queryParameters: {
      if (date != null) 'date': DateFormat('yyyy-MM-dd').format(date),
      'onlyMine': onlyMine,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> assignOccurrence(
      String id, String assignedTo, String? shift) async {
    final response = await _dio.patch('/shifts/occurrences/$id/assign', data: {
      'assignedTo': assignedTo,
      if (shift != null) 'shift': shift,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> updateStatus(
      String id, String status, String? notes) async {
    final response = await _dio.patch('/shifts/occurrences/$id/status',
        data: {'status': status, 'notes': notes});
    return response.data;
  }
}
