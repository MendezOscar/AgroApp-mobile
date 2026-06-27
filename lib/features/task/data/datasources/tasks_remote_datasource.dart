import 'package:dio/dio.dart';

class TasksRemoteDatasource {
  final Dio _dio;
  TasksRemoteDatasource(this._dio);

  Future<Map<String, dynamic>> getTasks({
    bool onlyMine = false,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get('/tasks', queryParameters: {
      'onlyMine': onlyMine,
      if (status != null) 'status': status,
      'page': page,
      'pageSize': pageSize,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> data) async {
    final response = await _dio.post('/tasks', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> updateStatus(
      String id, String status, String? notes) async {
    final response = await _dio
        .patch('/tasks/$id/status', data: {'status': status, 'notes': notes});
    return response.data;
  }

  Future<void> deleteTask(String id) async {
    await _dio.delete('/tasks/$id');
  }
}
