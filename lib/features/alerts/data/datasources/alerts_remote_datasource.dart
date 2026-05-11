import 'package:dio/dio.dart';

class AlertsRemoteDatasource {
  final Dio _dio;
  AlertsRemoteDatasource(this._dio);

  Future<List<dynamic>> getAlerts({bool onlyUnread = false}) async {
    final response =
        await _dio.get('/alerts', queryParameters: {'onlyUnread': onlyUnread});
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
