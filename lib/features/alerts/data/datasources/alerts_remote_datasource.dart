import 'package:dio/dio.dart';

class AlertsRemoteDatasource {
  final Dio _dio;
  AlertsRemoteDatasource(this._dio);

  Future<Map<String, dynamic>> getAlerts({
    bool onlyUnread = false,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get('/alerts', queryParameters: {
      'onlyUnread': onlyUnread,
      'page': page,
      'pageSize': pageSize,
    });
    return response.data;
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('/alerts/unread-count');
    return response.data as int;
  }

  Future<void> markAsRead(String id) async {
    await _dio.put('/alerts/$id/read');
  }
}
